page 50651 "Telegram Users"
{
    SourceTable = "Telegram Users";
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(Control)
            {
                field("Telegram User ID"; Rec."Telegram User ID")
                {
                    Caption = 'Telegram User';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Approval User ID"; Rec."Approval User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}