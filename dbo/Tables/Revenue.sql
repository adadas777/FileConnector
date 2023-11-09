CREATE TABLE [dbo].[Revenue] (
    [Dates]         DATETIME       NULL,
    [Type]          VARCHAR (1)    NULL,
    [Code]          VARCHAR (20)   NULL,
    [Price]         DECIMAL (5, 2) NULL,
    [Unit]          INT            NULL,
    [SubTotal]      DECIMAL (5, 2) NULL,
    [Brokeage Rate] DECIMAL (5, 2) NULL,
    [Tax]           DECIMAL (5, 2) NULL,
    [Stamp Duty]    DECIMAL (5, 2) NULL,
    [Clearing Fee]  DECIMAL (5, 2) NULL,
    [Amount]        DECIMAL (5, 2) NULL,
    [Svc Cost]      DECIMAL (5, 2) NULL
);

