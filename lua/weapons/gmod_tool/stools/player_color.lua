local string_format = string.format
local color_white = color_white
local IsValid = IsValid
local SERVER = SERVER
local Color = Color

TOOL.Name = "#tool.player_color.name"
TOOL.Category = "Render"

TOOL.RGB = { "r", "g", "b" }
for _, str in ipairs( TOOL.RGB ) do
	TOOL.ClientConVar[ str ] = 0
end

if CLIENT then
	TOOL.Information = {
		{
			["name"] = "left"
		},
		{
			["name"] = "right"
		},
		{
			["name"] = "reload"
		}
	}

	language.Add( "tool.player_color.name", "Player Color" )
	language.Add( "tool.player_color.desc", "Set a selected color like player color to ragdolls and other entities." )
	language.Add( "tool.player_color.left", "Set current color to entity" )
	language.Add( "tool.player_color.right", "Copy color from entity" )
	language.Add( "tool.player_color.reload", "Reset entity color to white" )
end

if SERVER then

	function TOOL:SetEntityColor( entity, color )
		if not IsValid( entity ) then return end
		if not IsColor( color ) then return end
		if type( entity.SetPlayerColor ) ~= "function" then return end

		entity:SetPlayerColor( color:ToVector() )
		duplicator.StoreEntityModifier( entity, "player_color", color )
	end

	duplicator.RegisterEntityModifier( "player_color", function( _, entity, data )
		TOOL.SetEntityColor( nil, entity, Color( data.r, data.g, data.b ) )
	end )

end

function TOOL:SetupColor( trace, color )
	local entity = trace.Entity
	if not IsValid( entity ) then
		return false
	end

	if entity:GetClass() == "prop_effect" then
		local attachedEntity = entity.AttachedEntity
		if IsValid( attachedEntity ) then
			entity = attachedEntity
		end
	end

	if SERVER then
		self:SetEntityColor( entity, color )
	end

	return true
end

function TOOL:LeftClick( trace )
	return self:SetupColor( trace, Color( self:GetClientNumber( "r", 0 ), self:GetClientNumber( "g", 0 ), self:GetClientNumber( "b", 0 ) ) )
end

function TOOL:Reload( trace )
	return self:SetupColor( trace, color_white )
end

function TOOL:RightClick( trace )
	local entity = trace.Entity
	if not IsValid( entity ) then
		return false
	end

	if IsValid( entity.AttachedEntity ) then
		entity = entity.AttachedEntity
	end

	local ply = self:GetOwner()
	if not IsValid( ply ) then
		return false
	end

	local color = entity:GetPlayerColor()
	if not color then return false end

	if SERVER then
		for i = 1, 3 do
			ply:ConCommand( string_format( "%s_%s \"%f\"", self:GetMode(), self.RGB[ i ], color[ i ] * 255 ) )
		end
	end

	return true
end

function TOOL.BuildCPanel( panel )
	panel:ColorPicker( "#tool.player_color.name", "player_color_r", "player_color_g", "player_color_b" )
end