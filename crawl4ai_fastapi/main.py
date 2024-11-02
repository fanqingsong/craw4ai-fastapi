import gc
import logging
from typing import Tuple

from crawl4ai import AsyncWebCrawler
from fastapi import FastAPI, HTTPException

from .models import Metadata, URLRequest, URLResponse
from .utils import extract_metadata

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()


async def crawl_content(url: str) -> Tuple[str, Metadata]:
    logger.info(f"Starting content crawling: {url}")

    # Run crawler within a context manager to ensure proper cleanup
    async with AsyncWebCrawler(
        verbose=True,
        user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    ) as crawler:
        result = await crawler.arun(
            url=url,
            screenshot=False,
            excluded_tags=["form"],
            exclude_external_links=False,
            exclude_social_media_links=True,
            exclude_external_images=False,
            remove_overlay_elements=True,
            html2text={
                "escape_dot": False,
            },
        )

    # Collect garbage after the crawler finishes
    gc.collect()

    # Check if result contains markdown content
    if result.markdown is None:
        raise Exception("Content crawling failed")

    # Extract metadata from the HTML result
    metadata = extract_metadata(result.html)

    logger.info(f"Content crawling completed: {url}")
    return result.markdown, metadata


@app.post("/crawl", response_model=URLResponse)
async def crawl_url(request: URLRequest):
    try:
        content, metadata = await crawl_content(request.url)
        return URLResponse(content=content, metadata=metadata)
    except Exception as e:
        logger.error(f"Error crawling content: {e}")
        raise HTTPException(status_code=500, detail=str(e))
