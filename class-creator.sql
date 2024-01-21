    CREATE TABLE Employees (
        EmployeeID int NOT NULL,
        LastName nvarchar(255) NOT NULL,
        FirstName nvarchar(255) NOT NULL,
        Title nvarchar(255) NULL,
        TitleOfCourtesy nvarchar(255) NULL,
        BirthDate datetime NULL,
        HireDate datetime NULL,
        Address nvarchar(255) NULL,
        City nvarchar(255) NULL,
        Region nvarchar(255) NULL,
        PostalCode nvarchar(255) NULL,
        Country nvarchar(255) NULL,
        HomePhone nvarchar(255) NULL,
        Extension nvarchar(255) NULL,
        Photo image NULL,
        Notes ntext NULL,
        ReportsTo int NULL,
        PhotoPath nvarchar(255) NULL
    );


DECLARE @TableName sysname = 'Employees'
DECLARE @Result varchar(max) = 'public class ' + @TableName + '
{'

SELECT @Result = @Result + '
    ' + RequiredAttribute + MaxLengthAttribute + '
    public ' + ColumnType + NullableSign + ' ' + ColumnName + ' { get; set; }
'
FROM
(
    SELECT
        replace(col.name, ' ', '_') ColumnName,
        column_id ColumnId,
        CASE typ.name
            WHEN 'bigint' THEN 'long'
            WHEN 'binary' THEN 'byte[]'
            WHEN 'bit' THEN 'bool'
            WHEN 'char' THEN 'string'
            WHEN 'date' THEN 'DateTime'
            WHEN 'datetime' THEN 'DateTime'
            WHEN 'datetime2' THEN 'DateTime'
            WHEN 'datetimeoffset' THEN 'DateTimeOffset'
            WHEN 'decimal' THEN 'decimal'
            WHEN 'float' THEN 'double'
            WHEN 'image' THEN 'byte[]'
            WHEN 'int' THEN 'int'
            WHEN 'money' THEN 'decimal'
            WHEN 'nchar' THEN 'string'
            WHEN 'ntext' THEN 'string'
            WHEN 'numeric' THEN 'decimal'
            WHEN 'nvarchar' THEN 'string' +
                CASE
                    WHEN col.is_nullable = 0 AND col.max_length = -1 THEN '' -- nvarchar(max) or ntext
                    ELSE ''
                END
            WHEN 'real' THEN 'float'
            WHEN 'smalldatetime' THEN 'DateTime'
            WHEN 'smallint' THEN 'short'
            WHEN 'smallmoney' THEN 'decimal'
            WHEN 'text' THEN 'string'
            WHEN 'time' THEN 'TimeSpan'
            WHEN 'timestamp' THEN 'long'
            WHEN 'tinyint' THEN 'byte'
            WHEN 'uniqueidentifier' THEN 'Guid'
            WHEN 'varbinary' THEN 'byte[]'
            WHEN 'varchar' THEN 'string' +
                CASE
                    WHEN col.is_nullable = 0 AND col.max_length = -1 THEN '' -- varchar(max) or text
                    WHEN col.is_nullable = 0 THEN '[' + CASE WHEN col.max_length > 0 THEN CAST(col.max_length AS varchar) ELSE 'Max' END + ']'
                    ELSE ''
                END
            ELSE 'UNKNOWN_' + typ.name
        END ColumnType,
        CASE
            WHEN col.is_nullable = 1 AND typ.name IN ('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier')
            THEN '?'
            ELSE ''
        END NullableSign,
        CASE
            WHEN col.is_nullable = 0 AND typ.name IN ('nvarchar', 'varchar')
            THEN
                CASE
                    WHEN col.max_length = -1 THEN '[MaxLength]' -- nvarchar(max) or varchar(max)
                    WHEN col.max_length > 0 THEN '[MaxLength(' + CAST(col.max_length / 2 AS varchar) + ')]'
                    ELSE ''
                END
            ELSE ''
        END MaxLengthAttribute,
        CASE
            WHEN col.is_nullable = 0 AND typ.name IN ('nvarchar', 'varchar')
            THEN '[Required(ErrorMessage = "The ' + replace(col.name, '_', ' ') + ' is required")]'
            ELSE ''
        END RequiredAttribute
    FROM sys.columns col
        JOIN sys.types typ ON col.system_type_id = typ.system_type_id AND col.user_type_id = typ.user_type_id
    WHERE object_id = object_id(@TableName)
) t
ORDER BY ColumnId

SET @Result = @Result  + '
}'

PRINT @Result