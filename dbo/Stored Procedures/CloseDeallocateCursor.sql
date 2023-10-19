






CREATE PROCEDURE [dbo].[CloseDeallocateCursor]
	
	@cursorname NVARCHAR(100)

AS
BEGIN

	DECLARE 
		@sql NVARCHAR(1000)
		, @procname VARCHAR(50)
		, @message NVARCHAR(4000)

	SET @procname = OBJECT_NAME(@@PROCID)
	

	BEGIN TRY
		
		EXEC dbo.SaveLog
			@message = 'Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		IF CURSOR_STATUS('global',@cursorname) >= -1
			
			BEGIN
				
				IF CURSOR_STATUS('global',@cursorname) > -1

				BEGIN

					SET @sql = 'CLOSE ' + @cursorname
					EXEC sp_executesql @sql

				END


				SET @sql = 'DEALLOCATE ' + @cursorname
				EXEC sp_executesql @sql

			END

		EXEC dbo.SaveLog
			@message = 'Ending procedure'
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