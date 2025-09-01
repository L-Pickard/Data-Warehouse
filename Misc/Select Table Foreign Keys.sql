SELECT 
    fk.name AS ForeignKeyName,
    fk.parent_object_id AS ParentObjectId,
    tp.name AS ParentTable,
    fk.referenced_object_id AS ReferencedObjectId,
    tr.name AS ReferencedTable
FROM 
    sys.foreign_keys AS fk
JOIN 
    sys.tables AS tp ON fk.parent_object_id = tp.object_id
JOIN 
    sys.tables AS tr ON fk.referenced_object_id = tr.object_id
WHERE 
    tr.name = 'dItem';
