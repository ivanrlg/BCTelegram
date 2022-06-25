codeunit 50653 "Telegram Events"
{
    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertEvent(var Rec: Record "Approval Entry"; RunTrigger: Boolean)
    var
        Telegram: codeunit Telegram;
        UserSetupFrom: Record "User Setup";
        TelegramUsers: Record "Telegram Users";
        MessageText: Text;
        MessageLabel: Label 'The user %1 requires your approval in the company %2 for the following document: %3';
    begin
        if not RunTrigger then begin
            exit;
        end;

        MessageText := StrSubstNo(MessageLabel, Rec."Sender ID", COMPANYNAME, GetType(Rec));

        TelegramUsers.SetRange("Approval User ID", Rec."Approver ID");
        if TelegramUsers.FindLast() then begin
            Telegram.SendMessage(TelegramUsers."Telegram Chat ID", MessageText);
        end else begin
            Message('The message to Telegram  %1 \ could not be sent, the user was not found in the Telegram Setup table.', MessageText);
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', true, true)]
    local procedure OnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        Telegram: codeunit Telegram;
        TelegramUsers: Record "Telegram Users";
        MessageText: Text;
        MessageLabel: Label 'User %1 has approved document %2 in company %3';
    begin

        MessageText := StrSubstNo(MessageLabel, ApprovalEntry."Approver ID", COMPANYNAME, GetType(ApprovalEntry));

        TelegramUsers.SetRange("Approval User ID", ApprovalEntry."Sender ID");
        if TelegramUsers.FindLast() then begin
            Telegram.SendMessage(TelegramUsers."Telegram Chat ID", MessageText);
        end else begin
            Message('The message to Telegram  %1 \ could not be sent, the user was not found in the Telegram Setup table.', MessageText);
        end;
    end;


    procedure GetType(Rec: Record "Approval Entry"): Text
    var
        BankAccHeader: Record "Bank Acc. Reconciliation";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        ReversalEntry: Record "Reversal Entry";
        GenLedgerRegister: Record "G/L Register";
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        Case Rec."Table ID" of
            Database::"Reversal Entry":
                begin
                    ReversalEntry.Get(Rec."Record ID to Approve");
                    exit('Reversal Entry: ' + ReversalEntry."Document No.");
                end;
            Database::"G/L Register":
                begin
                    GenLedgerRegister.Get(Rec."Record ID to Approve");
                    exit('GenLedgerRegister: ' + Format(GenLedgerRegister."No."));
                end;
            Database::"Gen. Journal Batch":
                begin
                    if GenJournalBatch.Get(Rec."Record ID to Approve") then begin
                        exit('Gen. Journal Batch: ' + GenJournalBatch.Name
                        + ' | Journal Template Name ' + GenJournalBatch."Journal Template Name");
                    end;
                end;
            Database::"Bank Acc. Reconciliation":
                begin
                    BankAccHeader.Get(Rec."Record ID to Approve");
                    exit('Bank Acc. Reconciliation: ' + Format(BankAccHeader."Bank Account No."));
                end;
            Database::"Purchase Header":
                begin
                    PurchaseHeader.Get(Rec."Record ID to Approve");
                    exit('Purchase ' + Format(PurchaseHeader."Document Type") + ' ' + Format(PurchaseHeader."No."));
                end;
            Database::"Sales Header":
                begin
                    SalesHeader.Get(Rec."Record ID to Approve");
                    exit('Sales ' + Format(SalesHeader."Document Type") + ' ' + Format(SalesHeader."No."));
                end;
        end
    end;

}
