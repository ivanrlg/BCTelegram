table 50650 "Telegram Setup"
{
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }

        field(2; Token; Text[100])
        {
        }

        //https://core.telegram.org/bots/api#getupdates
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;

}

