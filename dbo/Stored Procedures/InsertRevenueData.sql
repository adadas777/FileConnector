







CREATE PROCEDURE [dbo].[InsertRevenueData]
	
	@filepath NVARCHAR(500)
AS
BEGIN

	DECLARE 
		
		@json NVARCHAR(MAX)
		, @sql NVARCHAR(MAX)
		, @message NVARCHAR(4000)
		, @procname VARCHAR (50)
		, @id INT
		, @filename NVARCHAR(256)
		, @source NVARCHAR(256)

	SET @procname = OBJECT_NAME(@@PROCID)
	
	EXEC dbo.SaveLog
		@message = 'Starting procedure'
		, @source = @procname
		, @type = 'INFO'

	SELECT 
		@id = id
		, @filename = [FileName]
		, @source = [Source]
	FROM Files 
	WHERE [Source] + '\ ' + [FileName] = @filepath

	EXEC dbo.SaveFile
		@id = @id
		, @filename = @filename
		, @source = @source
		, @status = 'PROCESSING'
		, @errormessage = null
		, @direction = 'IN'
		

	BEGIN TRY

		SET @sql = N'
			SELECT @json= bulkcolumn
			FROM OPENROWSET(bulk  ''' + @filepath + ''', SINGLE_CLOB) importfile'

			Exec sp_executesql @Sql
							, N'@json NVARCHAR(MAX) OUTPUT'
							, @json OUTPUT;

	
	
		INSERT INTO [dbo].[RevenueTable]
		SELECT *
		FROM OPENJSON (@JSON)
		WITH

		(
			[Dates][DATETIME]
			, [Type][VARCHAR](1)
			, [Code][VARCHAR](20)
			, [Price] DECIMAL(5,2)
			, [Unit][INT]
			, [SubTotal] DECIMAL(5,2)
			, [Brokeage Rate] DECIMAL(5,2)
			, [Tax] DECIMAL(5,2)
			, [Stamp Duty] DECIMAL(5,2)
			, [Clearing Fee] DECIMAL(5,2)
			, [Amount] DECIMAL(5,2)
			, [Svc Cost] DECIMAL(5,2)
		) 

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
			, @direction ='IN'


		RETURN -1
	
	END CATCH 

		EXEC dbo.SaveFile
			@id = @id
			, @filename = @filename
			, @source = @source
			, @status ='FINISHED'
			, @errormessage = null
			, @direction = 'IN'

		SET @message = 'Insert file from: ' + @filepath + ' to ' + '[dbo].[TableJSON]'
	
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'INFO'
	
		EXEC dbo.SaveLog
			@message ='Ending procedure'
			, @source = @procname
			, @type = 'INFO'

	RETURN 0
END