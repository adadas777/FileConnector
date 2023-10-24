









CREATE PROCEDURE [dbo].[InsertOrganizationData]

	 @filepath NVARCHAR(500)
	 , @firstrow INT
	 , @fieldterminator NVARCHAR(5)
	 , @rowterminator NVARCHAR(5)

AS
BEGIN

	DECLARE 
		@sql NVARCHAR(2000)
		, @message NVARCHAR(4000)
		, @procname VARCHAR(50)

	SET @procname = OBJECT_NAME(@@PROCID)
	
	BEGIN TRY
		
		EXEC dbo.SaveLog
			@message ='Starting procedure'
			, @source = @procname
			, @type = 'INFO'

		SET @sql = 
			   N'BULK INSERT [dbo].[Organization] FROM ''' + @filepath 
			   + N''' WITH (FIRSTROW = ' + CAST(@firstrow as VARCHAR(5)) 
			   + ', FIELDTERMINATOR = ''' + @fieldterminator + ''', ROWTERMINATOR = ''' 
			   + @rowterminator + ''', 
			   ERRORFILE=''C:\MYWORKING\Source\a.' 
			   + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(VARcHAR(20)
			   , GETDATE(),121),'-',''),':',''),' ',''),'.','')+''')'

		SELECT 
			@filepath
			, @firstrow
			, @fieldterminator
			, @rowterminator 
				
		EXEC sp_executesql @sql

		SET @message = 'Insert file from: '+ @filepath + ' to ' + '[dbo].[Organization]'
	
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