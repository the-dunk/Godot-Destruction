This is the original version of the WIP destruction system that went on hiatus due to taking on a new job almost immediately after posting about the project. I eventually decided it was silly to have this repo sitting out here with absolutely no code to even look at for anyone curious.

Fair warning, this stuff is very rough. This was done in a project for my at-the-time game idea, so it was kind of just slapped onto a generic 3D camera controller. There is borderline no commenting to speak of-- trust me, I've learned that lesson after trying to comprehend the inner workings of the insane person who made this three years ago. Me.

Does it work? Kind of. I think there may have been some slight breaking changes between when it was made and now on an engine level, so certain things are a little jankier when cutting (lots of meshes stretching into the infinite abyss). The overall logic in the app, if you can walk through it, is still more-or-less sound. At the time I don't know if I understood winding order, which I do now, so when reconstructing tris they might be done in the wrong order. That means that they'll be flipped inside out and be transparent-- not great!

I have not abandoned this project entirely, trust me, I think about it regularly. This iteration of the project works as an _ok_ proof of concept for the logic, but it will not be used as the base going forward. 
I will ideally in the future actually start this from scratch in its own project, _actually comment everything_, and improve functionality. I am working on a much simpler game project right now, so it may be a while before I work on this further.



Since this is what we have right now, though, here's instructions on how to try this out:

Use the latest version of [Godot](https://godotengine.org/download/windows/) and import from the OLD_VERSIONS folder. When starting the project the immediately opened scene should be tempmeshtesting.tscn. The code that contains the bulk of cutting logic is found in TEST_CAMERA.gd, but there is also a small amount of logic for understanding mesh construction in giveinfo.gd, which is found on the actual mesh.

Start the scene in the normal way (top right) and you can then control the camera that manages cutting. 
- Camera controls: WASD + mouselook
- Release mouse: ~
- Close scene: ESC
- Cut: Left click on model (hold down and look around to determine direction) and release
- Hide debug objects: Z (this will remove both the red plane, normal/direction indicator, and reset mesh visualization)
- Mesh vizualization step forward: X (this only works if "Testing" is toggled on the mesh. Click on the Mesh node, check the node inspector on the right, toggle "Testing")

It is possible to cause a crash when cutting without having any direction (i.e. clicking without moving mouse), so make sure you input a direction.

My hope with releasing this extremely janky old code is to accomplish 2 things:
1. So that anyone else who has a desire to do their own destruction can get a slight jumping off point (if they are willing to suffer undocumented and completely obscure code)
2. To let the few people who have seen this repo at least see what was used to generate the initial gifs and know it wasn't just a fever dream!

Thanks for bearing with me!
