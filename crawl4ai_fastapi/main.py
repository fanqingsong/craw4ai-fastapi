import gc
import logging
from typing import Tuple
from urllib.parse import urlparse
from asyncio import TimeoutError
from asyncio import wait_for

from crawl4ai import AsyncWebCrawler
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.throttling import ThrottlingMiddleware
from pydantic_settings import BaseSettings

from .models import Metadata, URLRequest, URLResponse
from .utils import extract_metadata

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Add rate limiting middleware
app.add_middleware(
    ThrottlingMiddleware, 
    rate_limit=100,  # requests
    time_window=3600  # seconds
)

class Settings(BaseSettings):
    USER_AGENT: str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
    CRAWLER_TIMEOUT: int = 30
    REQUEST_TIMEOUT: int = 60

settings = Settings()


async def crawl_content(url: str) -> Tuple[str, Metadata]:
    logger.info(f"Starting content crawling: {url}")

    try:
        async with AsyncWebCrawler(
            verbose=True,
            user_agent=settings.USER_AGENT,
            timeout=settings.CRAWLER_TIMEOUT,  # Add timeout parameter
        ) as crawler:
            result = await wait_for(
                crawler.arun(
                    url=url,
                    screenshot=False,
                    excluded_tags=["form"],
                    exclude_external_links=False,
                    exclude_social_media_links=True,
                    exclude_external_images=False,
                    remove_overlay_elements=True,
                    html2text={"escape_dot": False,}
                ),
                timeout=settings.REQUEST_TIMEOUT  # Overall timeout for the operation
            )
    except TimeoutError:
        raise HTTPException(status_code=504, detail="Request timed out")

    # Collect garbage after the crawler finishes
    gc.collect()

    # Check if result contains markdown content
    if result.markdown is None:
        raise Exception("Content crawling failed")

    # Extract metadata from the HTML result
    metadata = extract_metadata(result.html)

    logger.info(f"Content crawling completed: {url}")
    return result.markdown, metadata


async def validate_url(url: str) -> bool:
    parsed = urlparse(url)
    return bool(parsed.netloc and parsed.scheme in ['http', 'https'])


@app.post("/crawl", response_model=URLResponse)
async def crawl_url(request: URLRequest):
    if not await validate_url(request.url):
        raise HTTPException(status_code=400, detail="Invalid URL format")
    try:
        content, metadata = await crawl_content(request.url)
        return URLResponse(content=content, metadata=metadata)
    except Exception as e:
        logger.error(f"Error crawling content: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
