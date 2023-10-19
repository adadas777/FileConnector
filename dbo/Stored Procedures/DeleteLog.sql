


CREATE PROCEDURE [dbo].[DeleteLog]

	@numberofdays INT

AS
BEGIN
	DECLARE

		@cleardate DATETIME

	SET @cleardate = DATEADD(DAY, -@numberofdays, GETDATE() )
	
	DELETE FROM [dbo].[Log]
	WHERE @cleardate >= [LogDate]

END;