# Unity Slime Shader
a slime shader built for use in VRChat and ChilloutVR

this shader utilizes raymarching for accurate looking refractions.

## Usage

download unity package from releases and install in unity project

when using in VRChat make sure to drag the DepthEnable prefab on your avatar. in ChilloutVR this is not needed

it is recommended to keep material render queue at `3010`

any transparent materials that would normally be around it such as blush should be at higher render queue such as `3011`

## Setting explanation

###### <img src="https://github.com/Exterrata/SlimeShader/assets/38149279/9c6dad87-aa0e-4ed0-b02f-86b8ef857db4" width="300">

<img src="https://github.com/Exterrata/SlimeShader/assets/38149279/11c5a593-0002-45e2-b45f-aa5149f1434e" width="300">

### Color
- Slime Color: tints the slime texture
- Slime Texture: texture used on any portion that is slime
- Slime Mask: blends between slime and non slime parts with white being completely slime and black being no slime effect
- Main Color: tints the Main Texture
- Main Texture: the texture used on any portion that is not slime

### LCH (luminance, chroma, hue)
- LCH Enabled: whether to use LCH
- LCH Mask Inverted: whether to invert the mask
- LCH Mask: black or white image wheter parts should be effected by LCH or not
- LCH: LCH values to use. `X` is `Luminance`, `Y` is `Chroma`, `Z` is `Hue`

### Effects
- Emmission Enabled: enable emmissions
- Emmission: the texture to use for emmisions

- ### Matcap
  - Matcap Enabled: whether to use matcaps
  - Matcap: matcap texture to use
  - Matcap Color: tints the matcap texture
  - Matcap Blur: how much to blur the matcap

- ### Normal Maps
  - Normal Map Enabled: whether to use Normal Mapping
  - Normal Map: the texture to use for normal mapping
    - Tiling: this controls the scale of the normal map
    - Offset: this controls the scrolling of the normal map
  - Normal Strength: strength of normal map effect

- ### Height Map (parallax)
  - Height Enabled: whether to use the height map
  - Height Map: black and white texture to use for height mapping
  - Height Strength: strength of the height map effect
  - Height Scale: scale of the height map effect

- ### Rim Lighting
  - Rim Light Enabled: whether to use rim lighting
  - Rim Power: power of rim light effect

### Reflections
- Reflections Enabled: whether to use reflections
- Metallic: controls the metallic of the material
- Smoothness: controls the Smoothness of the material
- Reflectivity: controls the reflectivity of the material

### Other
- Refraction Index: controls the refractivity of the slime
- Min Lighting: Minimum Lighting Limit
- Max Lighting: Maximum Lighting Limit
- Monochrome Lighting: controls how monochrome the lighting color is
- Bulge Enabled: whether to use depth bulge (not working)
- Bulge Amount: depth bulging amount
- Bulge Distance: depth bulging distance

### Slime Transparency
- Blur Enabled: whether to blur anything seen through the slime
- Slime Transparency: how transparent the slime is
- Depth Transparency: how transparency changes with depth of something seen though the slime
- Color Power: how much to shift the color of anything seen through the slime towards the slime color

## Preview images

<img src="https://github.com/Exterrata/SlimeShader/assets/38149279/c4e4aa9b-7e19-4254-b048-7c260dcfb488" height="400">

<img src="https://github.com/Exterrata/SlimeShader/assets/38149279/3029b8b7-1ede-4dd4-a8c2-8906e078017f" height="400">

<img src="https://github.com/Exterrata/SlimeShader/assets/38149279/17896473-7510-4605-9c8b-980aa48cd9f5" height="400">

## TODO
- improve reflections
- make depth bulge work
- move away from openlit
- custom inspector UI
