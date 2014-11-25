/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-base
use ooc-math
use ooc-draw-gpu

import OpenGLES3/ShaderProgram

OpenGLES3Map: abstract class extends GpuMap {
	_program: ShaderProgram
	_onUse: Func
	invertY: Float { get set }
	init: func (vertexSource: String, fragmentSource: String, onUse: Func) {
		this _onUse = onUse
		if (vertexSource == null || fragmentSource == null) {
			DebugPrint print("Vertex or fragment shader source not set")
			raise("Vertex or fragment shader source not set")
		}
		this _program = ShaderProgram create(vertexSource, fragmentSource)
	}
	dispose: func {
		if (this _program != null)
			this _program dispose()
	}
	use: func {
		this _program use()
		this _onUse()
		this _program setUniform("invertY", this invertY)
		this invertY = 1.0f
	}
}

OpenGLES3MapDefault: abstract class extends OpenGLES3Map {
	init: func (fragmentSource: String, onUse: Func) {
		super(This vertexSource, fragmentSource, func {
			onUse()
			})
	}
	vertexSource: static String
}

OpenGLES3MapTransform: class extends OpenGLES3Map {
	imageSize: IntSize2D { get set }
	transform: FloatTransform2D { get set }
	init: func (fragmentSource: String, onUse: Func) {
		super(This vertexSource, fragmentSource, func {
			onUse()
			this _program setUniform("imageWidth", this imageSize width)
			this _program setUniform("imageHeight", this imageSize height)
			arr := this transform to3DTransformArray()
			this _program setUniform("transform", arr)
			gc_free(arr)
			})

	}
	vertexSource: static String
}

OpenGLES3MapOverlay: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}
OpenGLES3MapLines: class extends OpenGLES3Map {
	color: FloatPoint3D { get set }
	init: func {
		super(This vertexSource, This fragmentSource,
			func {
				this _program setUniform("color", this color)
		})
	}
	vertexSource: static String
	fragmentSource: static String
}
OpenGLES3MapPoints: class extends OpenGLES3Map {
	color: FloatPoint3D { get set }
	pointSize: Float { get set }
	init: func {
		super(This vertexSource, This fragmentSource,
			func {
				this _program setUniform("color", this color)
				this _program setUniform("pointSize", this pointSize)
		})
	}
	vertexSource: static String
	fragmentSource: static String
}
OpenGLES3MapBlend: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapBgr: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapBgrToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapMonochrome: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}
OpenGLES3MapMonochromeTransform: class extends OpenGLES3MapTransform {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapUv: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapUvTransform: class extends OpenGLES3MapTransform {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapMonochromeToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapYuvPlanarToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("texture1", 1)
				this _program setUniform("texture2", 2)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapYuvSemiplanarToBgra: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("texture1", 1)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapYuvSemiplanarToBgraTransform: class extends OpenGLES3MapTransform {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("texture1", 1)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapPack: abstract class extends OpenGLES3MapDefault {
	imageWidth: Int { get set }
	init: func (fragmentSource: String) {
		super(fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("imageWidth", this imageWidth)
			})
	}
}

OpenGLES3MapPackMonochrome: class extends OpenGLES3MapPack {
	init: func {
		super(This fragmentSource)
	}
	fragmentSource: static String
}

OpenGLES3MapPackUv: class extends OpenGLES3MapPack {
	init: func {
		super(This fragmentSource)
	}
	fragmentSource: static String
}

OpenGLES3MapPackMonochrome1080p: class extends OpenGLES3MapPack {
	init: func {
		super(This fragmentSource)
	}
	fragmentSource: static String
}

OpenGLES3MapPackUv1080p: class extends OpenGLES3MapPack {
	init: func {
		super(This fragmentSource)
	}
	fragmentSource: static String
}

OpenGLES3MapUnpackMonochrome1080p: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapUnpackUv1080p: class extends OpenGLES3MapDefault {
	init: func {
		super(This fragmentSource,
			func {
				this _program setUniform("texture0", 0)
			})
	}
	fragmentSource: static String
}

OpenGLES3MapPyramidGeneration: abstract class extends OpenGLES3MapDefault {
	pyramidFraction: Float { get set }
	pyramidCoefficient: Float { get set }
	originalHeight: Int { get set }
	init: func (fragmentSource: String) {
		super(fragmentSource,
			func {
				this _program setUniform("texture0", 0)
				this _program setUniform("pyramidFraction", this pyramidFraction)
				this _program setUniform("pyramidCoefficient", this pyramidCoefficient)
				this _program setUniform("originalHeight", this originalHeight)
				})
			}
}

OpenGLES3MapPyramidGenerationDefault: class extends OpenGLES3MapPyramidGeneration {
	init: func { super(This fragmentSource) }
	fragmentSource: static String
}
OpenGLES3MapPyramidGenerationMipmap: class extends OpenGLES3MapPyramidGeneration {
	init: func { super(This fragmentSource) }
	fragmentSource: static String
}
