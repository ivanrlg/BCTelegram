codeunit 50651 Telegram
{
    trigger OnRun();
    begin
    end;

    var
        TelegramSetup: Record "Telegram Setup";

    procedure GetUpdates();
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        JsonValue: JsonValue;
        RequestLabel: label 'https://api.telegram.org/bot%1/getUpdates';
        InputText, RequestText : text;
    begin
        if not TelegramSetup.GET() then
            Error('Telegram Setup not found');

        TelegramSetup.TestField(Token);

        RequestText := StrSubstNo(RequestLabel, TelegramSetup.Token);

        if not Client.Get(RequestText, ResponseMessage) then
            Error(ResponseMessage.ReasonPhrase);

        if not ResponseMessage.IsSuccessStatusCode then
            Error(Format(ResponseMessage.IsSuccessStatusCode));

        ResponseMessage.Content.ReadAs(InputText);

        CreateTelegramUser(InputText);
    end;

    local procedure CreateTelegramUser(var InputText: text)
    var
        JsonObject: JsonObject;
        TelegramChatID: Integer;
        JsonT, JsonToken, JsonFrom, JsonMessage : JsonToken;
        TelegramCommand: Text;
    begin
        if InputText = '' then
            Error('Empty response');

        JsonObject.ReadFrom(InputText);

        JsonObject.SelectToken('result', JsonToken);

        foreach JsonT in JsonToken.AsArray do begin
            JsonMessage := GetJsonToken(JsonT.AsObject(), 'message');
            JsonFrom := GetJsonToken(JsonMessage.AsObject(), 'from');

            TelegramCommand := GetJsonToken(JsonMessage.AsObject(), 'text').AsValue.AsText();
            TelegramChatID := GetJsonToken(JsonFrom.AsObject(), 'id').AsValue.AsInteger();

            Insert(TelegramChatID, JsonFrom, TelegramCommand);
        end;
    end;

    local procedure Insert(var TelegramChatID: Integer; var JsonFrom: JsonToken; var TelegramCommand: Text)
    var
        UserSetup: Record "Telegram Users";
        MessageText: Label 'The user has been correctly configured to receive Workflow notifications.';
        UserNameToken: JsonToken;
        UserName: Text;
    begin
        if TelegramCommand.StartsWith('/subscribe') then begin

            if not JsonFrom.AsObject().Get('username', UserNameToken) then begin
                exit;
            end;

            UserName := UserNameToken.AsValue.AsText();

            if UserSetup.Get(TelegramChatID) then begin
                UserSetup."Telegram User ID" := UserName;
                UserSetup.Modify();
                exit;
            end;

            UserSetup.Init();
            UserSetup."Telegram User ID" := UserName;
            UserSetup."Telegram Chat ID" := TelegramChatID;
            UserSetup.Insert();

            SendMessage(TelegramChatID, MessageText);
        end;
    end;

    procedure SendMessage(TelegramChatID: Integer; MessageText: Text);
    var
        Client: HttpClient;
        ResponseMessage: HttpResponseMessage;
        RequestLabel: Label 'https://api.telegram.org/bot%1/sendMessage?chat_id=%2&text=%3';
        RequestText: Text;
    begin
        if not TelegramSetup.GET() then
            Error('Telegram Setup not found');

        TelegramSetup.TestField(Token);

        RequestText := StrSubstNo(RequestLabel, TelegramSetup.Token, TelegramChatID, MessageText);

        if not Client.Get(RequestText, ResponseMessage) then
            Error(ResponseMessage.ReasonPhrase);

        if not ResponseMessage.IsSuccessStatusCode then
            Error(Format(ResponseMessage.IsSuccessStatusCode));

    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;
}

