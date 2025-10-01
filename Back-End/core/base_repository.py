"""
Base Repository Pattern for database operations.
Reduces code duplication and standardizes database access.
"""
from typing import Any, Dict, List, Optional, TypeVar, Generic
from abc import ABC, abstractmethod
from core.common import supabase, logger

T = TypeVar('T')


class BaseRepository(ABC, Generic[T]):
    """Base repository for database operations"""
    
    def __init__(self, table_name: str):
        self.table_name = table_name
        self.db = supabase
        self.logger = logger
    
    async def create(self, data: Dict[str, Any]) -> Optional[T]:
        """Create a new record"""
        try:
            response = self.db.table(self.table_name).insert(data).execute()
            return response.data[0] if response.data else None
        except Exception as e:
            self.logger.error(f"Create failed in {self.table_name}: {str(e)}")
            raise
    
    async def get_by_id(self, record_id: str, id_column: str = "id") -> Optional[T]:
        """Get a record by ID"""
        try:
            response = self.db.table(self.table_name)\
                .select("*")\
                .eq(id_column, record_id)\
                .single()\
                .execute()
            return response.data if response.data else None
        except Exception as e:
            self.logger.error(f"Get by ID failed in {self.table_name}: {str(e)}")
            return None
    
    async def get_all(self, limit: Optional[int] = None) -> List[T]:
        """Get all records"""
        try:
            query = self.db.table(self.table_name).select("*")
            if limit:
                query = query.limit(limit)
            response = query.execute()
            return response.data if response.data else []
        except Exception as e:
            self.logger.error(f"Get all failed in {self.table_name}: {str(e)}")
            return []
    
    async def update(self, record_id: str, data: Dict[str, Any], id_column: str = "id") -> Optional[T]:
        """Update a record"""
        try:
            response = self.db.table(self.table_name)\
                .update(data)\
                .eq(id_column, record_id)\
                .execute()
            return response.data[0] if response.data else None
        except Exception as e:
            self.logger.error(f"Update failed in {self.table_name}: {str(e)}")
            raise
    
    async def delete(self, record_id: str, id_column: str = "id") -> bool:
        """Delete a record"""
        try:
            self.db.table(self.table_name)\
                .delete()\
                .eq(id_column, record_id)\
                .execute()
            return True
        except Exception as e:
            self.logger.error(f"Delete failed in {self.table_name}: {str(e)}")
            return False
    
    async def find_by(self, filters: Dict[str, Any]) -> List[T]:
        """Find records by filters"""
        try:
            query = self.db.table(self.table_name).select("*")
            for key, value in filters.items():
                query = query.eq(key, value)
            response = query.execute()
            return response.data if response.data else []
        except Exception as e:
            self.logger.error(f"Find by filters failed in {self.table_name}: {str(e)}")
            return []
    
    async def count(self, filters: Optional[Dict[str, Any]] = None) -> int:
        """Count records"""
        try:
            query = self.db.table(self.table_name).select("*", count="exact")
            if filters:
                for key, value in filters.items():
                    query = query.eq(key, value)
            response = query.execute()
            return response.count if hasattr(response, 'count') else 0
        except Exception as e:
            self.logger.error(f"Count failed in {self.table_name}: {str(e)}")
            return 0
    
    async def exists(self, record_id: str, id_column: str = "id") -> bool:
        """Check if a record exists"""
        record = await self.get_by_id(record_id, id_column)
        return record is not None
