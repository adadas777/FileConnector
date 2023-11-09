









CREATE PROCEDURE [dbo].[DeleteParameter]

	@key VARCHAR(50)

AS
BEGIN
	DECLARE 
		@message NVARCHAR(4000)
		, @source VARCHAR(200)
		, @type VARCHAR(10)
		, @procname VARCHAR(50)
	
	SET @key = TRIM(UPPER(@key))
	SET @procname = OBJECT_NAME(@@PROCID)

	BEGIN TRY
		
		EXEC dbo.SaveLog
			@message ='Starting procedure'
			, @source = @procname
			, @type = 'INFO'
		
		IF (SELECT CASE WHEN @key LIKE '%[^A-Z0-9_]%' THEN 1 ELSE 0 END) = 1
	
			BEGIN
				
				SET @message = CONCAT('Incorrect value @key ', @key)
			
				EXEC dbo.SaveLog
					@message = @message
					, @source = @procname
					, @type = 'ERROR'
			
				;THROW 51000, @message, 1;
			END

		IF NOT EXISTS (SELECT [Key] FROM [dbo].[Parameter] WHERE [Key] = @key) 
		
			BEGIN
				
				SET @message = 'Value @key not exists : ' + @key 

				EXEC dbo.SaveLog
					@message = @message
					, @source = @procname
					, @type = 'WARNING'
		
				;THROW 51000, @message, 1;
			END
	
		IF EXISTS (SELECT [Key] FROM [dbo].[Parameter] WHERE [Key] = @key)
		
			BEGIN
		
				SET @message = 'Deleted : '+ @key

				DELETE FROM 
					[dbo].[Parameter]
				WHERE
					[Key] = @key
				
			
				EXEC dbo.SaveLog
					@message = @message
					, @source = @procname
					, @type = 'INFO'
		
			END

		EXEC dbo.SaveLog
			@message ='Ending procedure'
			, @source = @procname
			, @type = 'INFO'

	END TRY 
		
	BEGIN CATCH
		
		SET @message = ERROR_MESSAGE()
		
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'ERROR'
		
		RETURN -1
	
	END CATCH

	RETURN 0
END