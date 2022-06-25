table 50651 "Telegram Users"
{
    fields
    {
        field(50650; "Telegram Chat ID"; Integer)
        {
        }
        field(50651; "Telegram User ID"; Text[70])
        {
        }
        field(50652; "Approval User ID"; Code[50])
        {
            TableRelation = "User Setup";
        }
    }

    keys
    {
        key(Key1; "Telegram Chat ID")
        {
            Clustered = true;
        }
    }
}