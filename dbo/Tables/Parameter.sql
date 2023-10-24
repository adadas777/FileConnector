CREATE TABLE [dbo].[Parameter] (
    [Key]         VARCHAR (50)   NOT NULL,
    [Value]       NVARCHAR (256) NOT NULL,
    [Destination] VARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_Parameter] PRIMARY KEY CLUSTERED ([Key] ASC)
);

