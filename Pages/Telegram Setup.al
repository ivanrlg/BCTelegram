page 50650 "Telegram Setup"
{
    PageType = Card;
    SourceTable = "Telegram Setup";
    ApplicationArea = All;
    UsageCategory = Administration;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Token"; Rec.Token)
                {
                    ApplicationArea = All;
                }
            }

            part(Users; "Telegram Users")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetUpdates)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = Refresh;
                Caption = 'Refresh User';
                ToolTip = 'If you are registering a user, you must first go to the Telegram Bot and type the /Subscribe command';
                trigger OnAction();
                var
                    Telegram: Codeunit "Telegram";
                begin
                    Telegram.GetUpdates;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Telegram: Codeunit "Telegram";
    begin

        Rec.InsertIfNotExists;
    end;
}

