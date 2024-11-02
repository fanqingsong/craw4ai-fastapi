import logging
from typing import Optional

from bs4 import BeautifulSoup, Tag
from .models import Metadata

logger = logging.getLogger(__name__)


def extract_metadata(html) -> Metadata:
    logger.info("Extracting metadata from HTML content")
    soup = BeautifulSoup(html, "html.parser")

    def get_tag_content(
        tag: str, attrs: dict, attr_name: str = "content"
    ) -> Optional[str]:
        """
        Find the first tag matching the given attributes and return the first non-empty content.
        """
        elements = soup.find_all(tag, attrs=attrs)  # Find all matching tags
        for element in elements:
            if isinstance(element, Tag) and element.has_attr(attr_name):
                content = element[attr_name]
                if isinstance(content, str):
                    content = content.strip()
                    if content:
                        return content
        return None  # Return None if no non-empty content found

    # Extract metadata with fallbacks
    title_tag = soup.find("title")
    title = (
        get_tag_content("meta", {"property": "og:title"})
        or get_tag_content("meta", {"property": "twitter:title"})
        or (title_tag.text if title_tag else "No title found")
    )

    description = (
        get_tag_content("meta", {"property": "og:description"})
        or get_tag_content("meta", {"name": "description"})
        or get_tag_content("meta", {"name": "Description"})
        or get_tag_content("meta", {"name": "twitter:description"})
        or "No description found"
    )
    image_url = (
        get_tag_content("meta", {"property": "og:image"})
        or get_tag_content("meta", {"name": "twitter:image"})
        or None
    )

    canonical_url = get_tag_content("link", {"rel": "canonical"}, "href")
    # keywords = get_tag_content("meta", {"name": "keywords"})

    return Metadata(
        title=title,
        description=description,
        image_url=image_url,
        canonical_url=canonical_url,
        # keywords=keywords,
    )
