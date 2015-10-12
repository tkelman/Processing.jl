include("typographyaux.jl")

export text, textFont, textSize
export textWidth, textHeight, textAscent, textDescent

## Loading & Displaying

#loadFont

function text(str::String, x, y)
	x = ((x+1)/2)*state.width
    xo = x
	y = ((y+1)/2)*state.height
    yo = y

	switchShader("fontDrawing")
	glActiveTexture(GL_TEXTURE1)
    glEnable(GL_CULL_FACE)

    posData = zeros(GLfloat, 2*6*length(str))
    texData = zeros(GLfloat, 2*6*length(str))

    n = 0
    totyadv = 0
    nforline = 0
	for c in str
        # if we hit a newline character or we reach the max line
        # length, then move to next line, where the next line is
        # determined by the average y advance from the characters
        # of the previous line.
        if c == '\n' || nforline == fontState.maxLineLength
            cht = fontState.characters[str[1]]
            x = xo
            y -= totyadv/nforline
            totyadv = 0
            nforline = 0
            continue
        end

		ch = fontState.characters[c]

		@inbounds xpos = x + ch.bearing[1] * state.textSize
        @inbounds ypos = y - (ch.size[2] - ch.bearing[2]) * state.textSize

        @inbounds w = ch.size[1] * state.textSize
        @inbounds h = ch.size[2] * state.textSize

        @inbounds totyadv += ch.advance[2] * state.textSize

        if w == 0 || h == 0
            continue
        end

        @inbounds posData[n+1] = xpos
        @inbounds posData[n+2] = ypos + h

        @inbounds posData[n+3] = xpos
        @inbounds posData[n+4] = ypos

        @inbounds posData[n+5] = xpos + w
        @inbounds posData[n+6] = ypos

        @inbounds posData[n+7] = xpos
        @inbounds posData[n+8] = ypos + h

        @inbounds posData[n+9] = xpos + w
        @inbounds posData[n+10] = ypos

        @inbounds posData[n+11] = xpos + w
        @inbounds posData[n+12] = ypos + h

        @inbounds texData[n+1] = ch.atlasOffset
        @inbounds texData[n+2] = 0.0

        @inbounds texData[n+3] = ch.atlasOffset
        @inbounds texData[n+4] = ch.size[2] / fontState.atlasHeight

        @inbounds texData[n+5] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds texData[n+6] = ch.size[2] / fontState.atlasHeight

        @inbounds texData[n+7] = ch.atlasOffset
        @inbounds texData[n+8] = 0.0

        @inbounds texData[n+9] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds texData[n+10] = ch.size[2] / fontState.atlasHeight

        @inbounds texData[n+11] = ch.atlasOffset + ch.size[1] / fontState.atlasWidth
        @inbounds texData[n+12] = 0.0

		@inbounds x += ch.advance[1] * state.textSize
        n += 2*6
        nforline += 1
	end
    glBindBuffer(GL_ARRAY_BUFFER, globjs.posvbos[globjs.posind])
    glBufferData(GL_ARRAY_BUFFER, sizeof(posData), posData, GL_STATIC_DRAW)
    glBindBuffer(GL_ARRAY_BUFFER, globjs.texvbos[globjs.texind])
    glBufferData(GL_ARRAY_BUFFER, sizeof(texData), texData, GL_STATIC_DRAW)
    glDrawArrays(GL_TRIANGLES, 0, 6*length(str))

    glDisable(GL_CULL_FACE)
	switchShader("basicShapes")
end

function textFont(fontname::String)
    # for the time being, we only allow system fonts or those that have been
    # installed directly into the main system storage
    @windows_only state.fontFace = "C:/Windows/Fonts/"*fontname
    @linux_only state.fontFace = "/usr/share/fonts/"*fontname
    @osx_only state.fontFace = "/System/Library/Fonts/"*fontname
    fontState = fontStruct(newface(state.fontFace), Dict(' ' => blankChar), 0, 12)
	setpixelsize(fontState.face, fontState.fontWidth, fontState.fontHeight)
	setupFontCharacters()
end

## Attributes

#function textAlign()
#
#end

#textLeading
#textMode

function textSize(size)
	state.textSize = size
end

function textWidth(str::String)
    # extents = Cairo.text_extents(cr, str)
    # return extents[1]
end

function textHeight(str::String)
    # extents = Cairo.text_extents(cr, str)
    # return extents[2]
end

## Metrics

function textAscent(str::String)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[1]
end

function textDescent(str::String)
   # extents = Cairo.scaled_font_extents(cr, str)
   # return extents[2]
end

function textLineLength(l)
    fontState.maxLineLength = l
end