

CREATE PROCEDURE [dbo].[SaveLog]
	
	@message NVARCHAR(4000)
	, @source VARCHAR(200)
	, @type VARCHAR(10)

AS
BEGIN

	INSERT INTO dbo."Log"
	(
		"Message"
		, "Source"
		, "Type"
		, "LogDate"
	)
	VALUES
	(
		@message
		, @source
		, @type
		, GETDATE()
	)
	
END