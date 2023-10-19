



CREATE PROCEDURE [dbo].[InsertCostumersData]
	
	@filepath NVARCHAR(500)
AS
BEGIN

	  DECLARE 
		@xml XML
		, @sql NVARCHAR(1000)
		, @message NVARCHAR(4000)
		, @procname VARCHAR(50)
		, @id INT
		, @filename NVARCHAR(256)
		, @source NVARCHAR(256)

	SET @procname = OBJECT_NAME(@@PROCID)
	
	BEGIN TRY
		
		EXEC dbo.SaveLog
			@message ='Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		SELECT 
			@id = id
			, @filename = [FileName]
			, @source = [Source] 
		FROM Files 
		WHERE [Source] + '\' + [FileName] = @filepath
			
		EXEC dbo.SaveFile
			@id = @id
			, @filename = @filename
			, @source = @source
			, @status = 'PROCESSING'
			, @errormessage = null
			, @direction = 'IN'

		SET @sql = 'SET @xml = (SELECT * FROM OPENROWSET (BULK ''' + @filePath + ''', SINGLE_CLOB) AS XmlData)'
      
		EXEC sp_executesql 
				 @sql 
				, N'@xml XML OUTPUT' 
				, @xml OUTPUT;

		INSERT INTO dbo.CostumersTable
		SELECT
			Customer.value('@Id','INT') AS Id 
			, Customer.value('(Name/text())[1]', 'VARCHAR(100)') AS Name 
			, Customer.value('(Country/text())[1]', 'VARCHAR(100)') AS Country 
		FROM @xml.nodes('/Customers/Customer') AS TEMPTABLE(Customer)

	END TRY

	BEGIN CATCH

		SET @message = 'Error when import file: ' + ERROR_MESSAGE()
		
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'ERROR'
		
		SET @message = ERROR_MESSAGE()
	
		EXEC dbo.SaveFile
			@id = @id
			, @filename = @filename
			, @source = @source
			, @status = 'ERROR'
			, @errormessage = @message
			, @direction = 'IN'


		RETURN -1
	
	END CATCH 

		EXEC dbo.SaveFile
			@id = @id
			, @filename = @filename
			, @source = @source
			, @status = 'FINISHED'
			, @errormessage = null
			, @direction = 'IN'
		
		SET @message = 'Insert file from: ' + @filepath + ' to ' + '[dbo].[TableXML]'
	
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'INFO'
	
		EXEC dbo.SaveLog
			@message = 'Ending procedure'
			, @source = @procname
			, @type = 'INFO'

	RETURN 0
END