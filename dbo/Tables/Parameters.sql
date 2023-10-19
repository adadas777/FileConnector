CREATE TABLE [dbo].[Parameters] (
    [Key]         VARCHAR (50)   NOT NULL,
    [Value]       NVARCHAR (256) NOT NULL,
    [Destination] VARCHAR (50)   NOT NULL,
    CONSTRAINT [PK_Parameters] PRIMARY KEY CLUSTERED ([Key] ASC)
);


GO
CREATE NONCLUSTERED INDEX [I_Destination]
    ON [dbo].[Parameters]([Destination] ASC);

