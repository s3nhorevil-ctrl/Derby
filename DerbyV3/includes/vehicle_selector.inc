/*
    DERBY V3 - VEHICLE SELECTOR
    
    Sistema de selecao de veiculo com preview 3D
    usando TextDraw preview model.
*/

#if defined _vehicle_selector_included
    #endinput
#endif
#define _vehicle_selector_included

// =============================================================================
// TEXTDRAW DE PREVIEW DO VEICULO
// =============================================================================

new Text:TD_VehiclePreview;
new Text:TD_VehiclePreviewName;
new Text:TD_VehiclePreviewBG;

stock CreateVehiclePreviewTextDraws()
{
    // Background box
    TD_VehiclePreviewBG = TextDrawCreate(430.0, 180.0, "_");
    TextDrawLetterSize(TD_VehiclePreviewBG, 0.0, 12.0);
    TextDrawTextSize(TD_VehiclePreviewBG, 560.0, 0.0);
    TextDrawUseBox(TD_VehiclePreviewBG, 1);
    TextDrawBoxColor(TD_VehiclePreviewBG, 0x00000099);
    TextDrawFont(TD_VehiclePreviewBG, 1);
    
    // Preview model (3D vehicle)
    TD_VehiclePreview = TextDrawCreate(495.0, 190.0, "_");
    TextDrawFont(TD_VehiclePreview, 5); // Font 5 = Preview Model
    TextDrawTextSize(TD_VehiclePreview, 100.0, 100.0); // Size of preview
    TextDrawSetPreviewModel(TD_VehiclePreview, 411); // Default Infernus
    TextDrawSetPreviewRot(TD_VehiclePreview, -16.0, 0.0, -55.0, 1.0);
    TextDrawBackgroundColor(TD_VehiclePreview, 0x00000000);
    TextDrawColor(TD_VehiclePreview, 0xFFFFFFFF);
    
    // Nome do veiculo abaixo do preview
    TD_VehiclePreviewName = TextDrawCreate(495.0, 295.0, "Infernus");
    TextDrawLetterSize(TD_VehiclePreviewName, 0.3, 1.2);
    TextDrawAlignment(TD_VehiclePreviewName, 2);
    TextDrawColor(TD_VehiclePreviewName, 0xFFFF00FF);
    TextDrawSetOutline(TD_VehiclePreviewName, 1);
    TextDrawFont(TD_VehiclePreviewName, 2);
    TextDrawSetProportional(TD_VehiclePreviewName, 1);
}

// =============================================================================
// MOSTRAR PREVIEW
// =============================================================================

stock ShowVehiclePreview(playerid, modelid)
{
    TextDrawSetPreviewModel(TD_VehiclePreview, modelid);
    new vname[24];
    GetVehicleNameByModel(modelid, vname, sizeof(vname));
    TextDrawSetString(TD_VehiclePreviewName, vname);
    
    TextDrawShowForPlayer(playerid, TD_VehiclePreviewBG);
    TextDrawShowForPlayer(playerid, TD_VehiclePreview);
    TextDrawShowForPlayer(playerid, TD_VehiclePreviewName);
}

stock HideVehiclePreview(playerid)
{
    TextDrawHideForPlayer(playerid, TD_VehiclePreviewBG);
    TextDrawHideForPlayer(playerid, TD_VehiclePreview);
    TextDrawHideForPlayer(playerid, TD_VehiclePreviewName);
}
