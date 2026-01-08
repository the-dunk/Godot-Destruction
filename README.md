# Godot-Destruction
An open-source library for real-time mesh destruction in Godot 4.x

The methods are designed to operate at runtime, with minimal impact on performance. It is important to note that these functions are designed **for convex meshes**. Using concave meshes may cause unintended results and I cannot guarantee performance in those cases. The primary use case is to take a base convex mesh and break it into smaller convex meshes, thus allowing rigid body physics to apply.

Meshes do not require any additional scripting on top, and only the objects or effects performing the destruction need to make use of the tools. Globally, a 'cut' material can be applied, as well as be applied per destruction tool or mesh, if a special case is desired. This material is what the 'inside' of a cut material will look like. Additionally a 'cut effect' can be applied as well, which can be a number of effects such as temporarily changing a material or having short-lived particle and lighting effects, allowing for more detailed effects indicating a cut to the user.

## Working, needs cleanup before posting

The 'basic' destruction (making slices and holes) makes use of consecutive plane slicing. Regular slices are done simply using a plane, with a variable 'width' associated to it (this simply adds an offset for the generated mesh vertices so that the cut meshes are not 0 units apart).

![Demonstration of the 'slice' function. A grey, metallic, pentagonal prism appears over a default Godot environment. The cursor is placed on the bottom right corner of the shape and dragged to the top left. A glowing orange line is generated along the path while sparks fly out. After reaching the top, the cursor is released, and all of the shape lying above the line disappears, leaving a smooth cut surface on the remaining mesh.](https://github.com/the-dunk/Godot-Destruction/assets/3682609/cb9cd539-57f9-4656-836e-cb69bf5bdc87)

_Demonstration of the 'slice' destruction, with the 'bottom' part of the cut removed for visual clarity._


![The same demonstration of the 'slice' function, but with an opposite cut direction. This shows the other piece that would be generated from the cut, with the same smooth surface.](https://github.com/the-dunk/Godot-Destruction/assets/3682609/77e719e2-2cdf-4908-937f-b3ec9397aa0f)

_The reverse of the previous cut._

The basic destruction functions will result in 2 distinct meshes with a tri count approximately equal to the original tri-count plus the number of faces that are cut by the plane. So, effectively, T<sub>m1</sub> + T<sub>m2</sub> = T<sub>M</sub> + 2*N<sub>cf</sub>. This means that performance may not be as effective on highly complex meshes, but your mileage may vary. Performance for basic destruction, however, should be quite good and suited for real-time applications. It should be noted that pre-computed destruction is still likely the superior option for applications where fully dynamic destruction is not essential, as it grants you far more control over triggers and what kind of debris will be generated, as well as being more predictable in terms of performance.

## In-Development

The 'complex' or 'fracture' destruction (breaking apart a mesh in irregular pieces) makes use of Voronoi generation to create a web of convex shapes that are then turned into multiple discrete meshes. A 'destroyer' effect can have a variable effect on both 'destruction' strength and 'fracture' strength.

Destruction strength dictates the amount of material that will be 'destroyed' in an area around the point of impact. This means that rather than 'break' into pieces, the lost material will simply be removed, with an optional 'lifetime' treating the leftover material as a few collisionless particles.

Fracture strength indicates the number and density of the collision points used for fracturing. High fracture strength means high amount and high density, meaning many small fragments created at the center of the impact, with many breaking off, spiderwebbing outward. Low strength means few points and low density, creating relatively large fragments with very few breaking off, requiring repeated impacts.

Any mesh allowed to be cut will obey the global destruction threshhold, which is the smallest volume that can be destroyed before becoming indestructible. It is heavily advised to tie this to settings to ensure there are not too many small objects sitting around for lower performance devices.

## Planned

'Continuous' destruction is a hybrid between 'basic' and 'complex' destruction. It allows for a continuous cut with different pipelines depending on the type of cut. If a cut starts at one end of the mesh and goes all the way to another side, it functions similarly to multiple consecutive slices. If a cut begins within a mesh and connects with itself (i.e. the line of the cut intersects a previous point on the cut) or is within a variable threshhold distance of another point on the mesh, a convex hull is generated around the cut points and used as though it is a hole. Finally, if a 'hole' is not drawn but the line also does not fully bisect the object, a special pipeline is used that effectively 'crops' the cut area down to the bounds of the cut, generating 3 initial meshes and applying the same line method as before to the center slice.
