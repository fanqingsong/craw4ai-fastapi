from typing import Optional

from pydantic import BaseModel


class Metadata(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    canonical_url: Optional[str] = None
    keywords: Optional[str] = None


class URLRequest(BaseModel):
    url: str


class URLResponse(BaseModel):
    content: str
    metadata: Metadata
