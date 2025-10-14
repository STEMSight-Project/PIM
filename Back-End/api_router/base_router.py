"""
Base API Router with common functionality for all routers.
Reduces boilerplate and standardizes error handling.
"""
from typing import Any, Dict, Optional, Callable, List, Sequence
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel
from core.common import logger


class StandardResponse(BaseModel):
    """Standard API response format"""
    success: bool
    message: str
    data: Optional[Any] = None
    error: Optional[str] = None


class BaseAPIRouter:
    """Base class for API routers with common functionality"""
    
    def __init__(self, prefix: str, tags: Sequence[str]):
        self.router = APIRouter(prefix=prefix, tags=list(tags))
        self.logger = logger
    
    def success_response(
        self, 
        message: str, 
        data: Any = None, 
        status_code: int = status.HTTP_200_OK
    ) -> Dict[str, Any]:
        """Create a standard success response"""
        return {
            "success": True,
            "message": message,
            "data": data
        }
    
    def error_response(
        self, 
        message: str, 
        error: Optional[str] = None,
        status_code: int = status.HTTP_400_BAD_REQUEST
    ) -> HTTPException:
        """Create a standard error response"""
        return HTTPException(
            status_code=status_code,
            detail={
                "success": False,
                "message": message,
                "error": error
            }
        )
    
    async def handle_db_operation(
        self, 
        operation: Callable, 
        success_message: str,
        error_message: str = "Database operation failed"
    ) -> Dict[str, Any]:
        """
        Handle database operations with standard error handling
        
        Args:
            operation: Async function to execute
            success_message: Message to return on success
            error_message: Message to return on error
            
        Returns:
            Standard response dictionary
            
        Raises:
            HTTPException on error
        """
        try:
            result = await operation()
            return self.success_response(success_message, result)
        except Exception as e:
            self.logger.error(f"{error_message}: {str(e)}")
            raise self.error_response(error_message, str(e))
    
    def log_request(self, endpoint: str, **kwargs):
        """Log incoming request"""
        self.logger.info(f"Request to {endpoint}", extra=kwargs)
    
    def log_response(self, endpoint: str, status: str, **kwargs):
        """Log outgoing response"""
        self.logger.info(f"Response from {endpoint}: {status}", extra=kwargs)
