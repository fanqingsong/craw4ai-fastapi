import gc
import logging
from asyncio import TimeoutError, wait_for
from typing import Tuple
from urllib.parse import urlparse

from crawl4ai import AsyncWebCrawler
from fastapi import FastAPI, HTTPException, Request
from pydantic_settings import BaseSettings
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from .models import Metadata, URLRequest, URLResponse
from .utils import extract_metadata

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Set up rate limiter
limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


class Settings(BaseSettings):
    USER_AGENT: str = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
    CRAWLER_TIMEOUT: int = 30
    REQUEST_TIMEOUT: int = 60
    RATE_LIMIT: str = "100/hour"  # Rate limit in format "number/period" (e.g., "100/hour", "1000/day")

    class Config:
        env_file = ".env"


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
                    html2text={
                        "escape_dot": False,
                    },
                ),
                timeout=settings.REQUEST_TIMEOUT,  # Overall timeout for the operation
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
    return bool(parsed.netloc and parsed.scheme in ["http", "https"])


@app.post("/crawl", response_model=URLResponse)
@limiter.limit(settings.RATE_LIMIT)  # Use rate limit from settings
async def crawl_url(
    url_request: URLRequest,
    request: Request,  # Required by the rate limiter to track client's IP address
):
    if not await validate_url(url_request.url):
        raise HTTPException(status_code=400, detail="Invalid URL format")
    try:
        content, metadata = await crawl_content(url_request.url)
        return URLResponse(content=content, metadata=metadata)
    except Exception as e:
        logger.error(f"Error crawling content: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
