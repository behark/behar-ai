"""
Minimal Enhanced Platform API for Railway Deployment
This is a streamlined version of the platform API designed to be minimal for Railway deployment.
"""

import json
import logging
import os
from typing import Any, Dict, List, Optional

import httpx
from fastapi import Depends, FastAPI, HTTPException, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger("enhanced_platform")

# Initialize FastAPI app
app = FastAPI(
    title="Enhanced Dimensional AI Platform",
    description="A production-ready AI Platform with minimal dependencies for Railway deployment",
    version="2.0.0",
)

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.environ.get("CORS_ALLOW_ORIGIN", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Get Ollama URL from environment
OLLAMA_BASE_URL = os.environ.get("OLLAMA_BASE_URL", "http://localhost:11434")
ENVIRONMENT = os.environ.get("ENVIRONMENT", "production")
PORT = int(os.environ.get("PORT", 8000))

# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring and load balancers"""
    return {
        "status": "healthy",
        "version": "2.0.0",
        "environment": ENVIRONMENT
    }

# API information endpoint
@app.get("/")
async def root():
    """API information endpoint"""
    return {
        "name": "Enhanced Dimensional AI Platform",
        "version": "2.0.0",
        "status": "online",
        "environment": ENVIRONMENT
    }

# Ollama models endpoint
@app.get("/api/models")
async def get_models():
    """Retrieve available models from Ollama"""
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(f"{OLLAMA_BASE_URL}/api/tags")
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"Ollama returned status code {response.status_code}")
                return {"error": "Failed to retrieve models from Ollama"}
    except Exception as e:
        logger.error(f"Error connecting to Ollama: {e}")
        return {"error": f"Failed to connect to Ollama: {str(e)}"}

# Model Request Schema
class ChatRequest(BaseModel):
    model: str
    messages: List[Dict[str, str]]
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 2048
    stream: Optional[bool] = False

# Chat completion endpoint
@app.post("/api/chat/completions")
async def chat_completion(request: ChatRequest, raw_request: Request):
    """Chat completion endpoint compatible with OpenAI format"""
    try:
        ollama_payload = {
            "model": request.model,
            "messages": request.messages,
            "options": {
                "temperature": request.temperature,
                "num_predict": request.max_tokens
            },
            "stream": request.stream
        }
        
        if request.stream:
            # Streaming response
            async def stream_response():
                async with httpx.AsyncClient(timeout=60.0) as client:
                    async with client.stream("POST", f"{OLLAMA_BASE_URL}/api/chat", json=ollama_payload) as response:
                        async for chunk in response.aiter_text():
                            if chunk:
                                try:
                                    yield f"data: {chunk}\n\n"
                                except Exception as e:
                                    logger.error(f"Error processing stream chunk: {e}")
                                    yield f"data: {json.dumps({'error': str(e)})}\n\n"
            
            return Response(content=stream_response(), media_type="text/event-stream")
        else:
            # Non-streaming response
            async with httpx.AsyncClient(timeout=60.0) as client:
                response = await client.post(f"{OLLAMA_BASE_URL}/api/chat", json=ollama_payload)
                if response.status_code == 200:
                    return response.json()
                else:
                    logger.error(f"Ollama returned status code {response.status_code}: {response.text}")
                    return {"error": "Failed to get completion from Ollama"}
    except Exception as e:
        logger.error(f"Error in chat completion: {e}")
        return {"error": f"Chat completion failed: {str(e)}"}

# Main entry point
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("enhanced_platform:app", host="0.0.0.0", port=PORT, reload=False)
