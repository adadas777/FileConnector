





CREATE PROCEDURE [dbo].[GetParameters]

	@key VARCHAR(50)
	, @value NVARCHAR(256) OUTPUT

AS
BEGIN
	
	DECLARE
		@message NVARCHAR(4000)
		, @procname VARCHAR(50)
	
	SET @procname = OBJECT_NAME(@@PROCID)
	
	BEGIN TRY
	
		EXEC dbo.SaveLog
			@message ='Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		Select @value = [Value]
		FROM [dbo].[Parameters]
		WHERE [Key] = @key

		SET @message = 'Got parameters: ' + @key + ', ' + @value
	
		EXEC dbo.SaveLog
			@message = @message
			, @source = @procname
			, @type = 'INFO'
	
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