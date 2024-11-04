#!/bin/bash
./build.sh
docker run -p 8000:8000 crawl4ai-fastapi
