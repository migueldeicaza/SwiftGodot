//
// Generator's Plugin definition.swift
//
//
//  Created by Miguel de Icaza on 4/4/23.
//

import Foundation
import PackagePlugin

/// Generates the API for the SwiftGodot from the Godot exported Json API
@main struct SwiftCodeGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let config = generationConfig(for: target.name) else {
            return []
        }

        let generator = try context.tool(named: "Generator").url

        let api = context.package.directoryURL
            .appending(["Sources", "ExtensionApi", "extension_api.json"])

        try FileManager.default.createDirectory(at: context.pluginWorkDirectoryURL, withIntermediateDirectories: true)

        let generatedSourcesDir = context.pluginWorkDirectoryURL
            .appending(path: "GeneratedSources")
            .appending(path: target.name)
        try FileManager.default.createDirectory(at: generatedSourcesDir, withIntermediateDirectories: true)

        let configurationDir = context.pluginWorkDirectoryURL.appending(path: "Configuration")
        try FileManager.default.createDirectory(at: configurationDir, withIntermediateDirectories: true)

        let classFilterFile = configurationDir.appending(path: "\(target.name)-classes.txt")
        let availableClassFilterFile = configurationDir.appending(path: "\(target.name)-available-classes.txt")
        let builtinFilterFile = configurationDir.appending(path: "\(target.name)-builtins.txt")

        if target.name == "SwiftGodot" {
            if config.generatedClassFiles.contains("Object.swift") {
                fatalError()
            }
        }
        try writeIfChanged(config.generatedClassFiles.joined(separator: "\n"), to: classFilterFile)
        try writeIfChanged(config.availableClassFiles.joined(separator: "\n"), to: availableClassFilterFile)
        try writeIfChanged(config.builtinFiles.joined(separator: "\n"), to: builtinFilterFile)

        var arguments = [api.path, generatedSourcesDir.path]
        var outputFiles: [URL] = []
#if os(Windows)
        // Windows has 32K limit on CreateProcess argument length, SPM currently doesn't handle it well.
        // We generate so many output files that passing them all into the build command would exceed the limit.
        // So instead we combine the output into 26 swift files, one for each letter of the alphabet, each containing
        // all the types that start with that letter.
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for letter in letters {
            outputFiles.append(generatedSourcesDir.appending(path: "SwiftGodot\(letter).swift"))
        }
        arguments.append(context.package.directoryURL.appending(path: "doc").path)
        arguments.append("--combined")
#else
        outputFiles.append(contentsOf: config.builtinFiles.map { generatedSourcesDir.appending(["generated-builtin", $0]) })
        outputFiles.append(contentsOf: config.generatedClassFiles.map { generatedSourcesDir.appending(["generated", $0]) })
#endif
        arguments.append(contentsOf: [
            "--class-filter", classFilterFile.path,
            "--available-class-filter", availableClassFilterFile.path,
            "--builtin-filter", builtinFilterFile.path
        ])

        var inputFiles: [URL] = [api, classFilterFile, availableClassFilterFile, builtinFilterFile]

        if let preamble = config.preamble, !preamble.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let preambleFile = configurationDir.appending(path: "\(target.name)-preamble.txt")
            try writeIfChanged(preamble, to: preambleFile)
            arguments.append(contentsOf: ["--preamble-file", preambleFile.path])
            inputFiles.append(preambleFile)
        }

        return [
            Command.buildCommand(
                displayName: "Generating SwiftGodot API for \(target.name)",
                executable: generator,
                arguments: arguments,
                inputFiles: inputFiles,
                outputFiles: outputFiles
            )
        ]
    }

    private func generationConfig(for targetName: String) -> GenerationConfig? {
        switch targetName {
        case "SwiftGodotRuntime":
            return GenerationConfig(
                classFiles: runtime.uniqued(),
                builtinFiles: knownBuiltin,
                preamble: nil
            )


        // Remove this target when we are able to split things up, for now
        // this target produces everything like we used to.
        //
        // This means that we do not need to bring the SwiftGodotRuntime, we
        // just generate everything the same way
        case "SwiftGodot":
            return GenerationConfig(
                classFiles: (core + controls + threeD + gltf + twoD + xr + editor + visualShaderNodes).uniqued(),
                builtinFiles: [],
                preamble: """
@_exported import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
""",
                dependencyClassFiles: runtime
            )

        case "SwiftGodotCore":
            return GenerationConfig(
                classFiles: core.uniqued(),
                builtinFiles: [],
                preamble: """
@_exported import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotRuntime
""",
                dependencyClassFiles: runtime
            )
        case "SwiftGodotControls":
            fallthrough
        case "SwiftGodot2D":
            fallthrough
        case "SwiftGodot3D":
            fallthrough
        case "SwiftGodotGLTF":
            fallthrough
        case "SwiftGodotXR":
            fallthrough
        case "SwiftGodotEditor":
            fallthrough
        case "SwiftGodotVisualShaderNodes":
            let classFiles: [String]
            let preamble: String
            let dependencyClassFiles: [String]
            switch targetName {
            case "SwiftGodotControls":
                classFiles = controls
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodot2D":
                classFiles = twoD
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodot3D":
                classFiles = threeD
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotGLTF":
                classFiles = gltf
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotXR":
                classFiles = xr
                preamble = """
@_exported import SwiftGodotCore
@_exported import SwiftGodotControls
@_exported import SwiftGodot3D
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotControls
@_spi(SwiftGodotRuntimePrivate) import SwiftGodot3D
"""
                dependencyClassFiles = core + controls + threeD + runtime
            case "SwiftGodotVisualShaderNodes":
                classFiles = visualShaderNodes
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            case "SwiftGodotEditor":
                classFiles = editor
                preamble = """
@_exported import SwiftGodotCore
@_exported import SwiftGodotControls
@_exported import SwiftGodot3D
@_exported import SwiftGodotGLTF
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotControls
@_spi(SwiftGodotRuntimePrivate) import SwiftGodot3D
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotGLTF
"""
                dependencyClassFiles = core + controls + threeD + gltf + runtime
            default:
                classFiles = []
                preamble = """
@_exported import SwiftGodotCore
@_spi(SwiftGodotRuntimePrivate) import SwiftGodotCore
"""
                dependencyClassFiles = core + runtime
            }
            return GenerationConfig(
                classFiles: classFiles.uniqued(),
                builtinFiles: [],
                preamble: preamble,
                dependencyClassFiles: dependencyClassFiles
            )
        default:
            return nil
        }
    }

    private func writeIfChanged(_ contents: String, to file: URL) throws {
        let data = Data(contents.utf8)
        if let existing = try? Data(contentsOf: file), existing == data {
            return
        }
        try data.write(to: file, options: [.atomic])
    }
}

struct GenerationConfig {
    let classFiles: [String]
    let builtinFiles: [String]
    let preamble: String?
    let dependencyClassFiles: [String]

    init(
        classFiles: [String],
        builtinFiles: [String],
        preamble: String?,
        dependencyClassFiles: [String] = []
    ) {
        self.classFiles = classFiles
        self.builtinFiles = builtinFiles
        self.preamble = preamble
        self.dependencyClassFiles = dependencyClassFiles
    }

    var generatedClassFiles: [String] {
        classFiles.uniqued()
    }

    var availableClassFiles: [String] {
        (classFiles + dependencyClassFiles).uniqued()
    }
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen: Set<String> = []
        return self.filter { seen.insert($0).inserted }
    }
}

let knownBuiltin = [
  "AABB.swift",
  "Array.swift",
  "Basis.swift",
  "Callable.swift",
  "Color.swift",
  "core-defs.swift",
  "Dictionary.swift",
  "NodePath.swift",
  "PackedByteArray.swift",
  "PackedColorArray.swift",
  "PackedFloat32Array.swift",
  "PackedFloat64Array.swift",
  "PackedInt32Array.swift",
  "PackedInt64Array.swift",
  "PackedStringArray.swift",
  "PackedVector2Array.swift",
  "PackedVector3Array.swift",
  "PackedVector4Array.swift",
  "Plane.swift",
  "Projection.swift",
  "Quaternion.swift",
  "Rect2.swift",
  "Rect2i.swift",
  "RID.swift",
  "Signal.swift",
  "String.swift",
  "StringName.swift",
  "Transform2D.swift",
  "Transform3D.swift",
  "utility.swift",
  "Vector2.swift",
  "Vector2i.swift",
  "Vector3.swift",
  "Vector3i.swift",
  "Vector4.swift",
  "Vector4i.swift",
]

let runtime: [String] = [
    "ClassDB.swift",
    "Object.swift",
    "Engine.swift",
    "RefCounted.swift",
]

let core: [String] = [
    "AESContext.swift",
    "AnimatedTexture.swift",
    "Animation.swift",
    "AnimationLibrary.swift",
    "AnimationMixer.swift",
    "AnimationNode.swift",
    "AnimationNodeAdd2.swift",
    "AnimationNodeAdd3.swift",
    "AnimationNodeAnimation.swift",
    "AnimationNodeBlend2.swift",
    "AnimationNodeBlend3.swift",
    "AnimationNodeBlendSpace1D.swift",
    "AnimationNodeBlendTree.swift",
    "AnimationNodeExtension.swift",
    "AnimationNodeOneShot.swift",
    "AnimationNodeOutput.swift",
    "AnimationNodeStateMachine.swift",
    "AnimationNodeStateMachinePlayback.swift",
    "AnimationNodeStateMachineTransition.swift",
    "AnimationNodeSub2.swift",
    "AnimationNodeSync.swift",
    "AnimationNodeTimeScale.swift",
    "AnimationNodeTimeSeek.swift",
    "AnimationNodeTransition.swift",
    "AnimationPlayer.swift",
    "AnimationRootNode.swift",
    "AnimationTree.swift",
    "ArrayMesh.swift",
    "AtlasTexture.swift",
    "AudioBusLayout.swift",
    "AudioEffect.swift",
    "AudioEffectAmplify.swift",
    "AudioEffectBandLimitFilter.swift",
    "AudioEffectBandPassFilter.swift",
    "AudioEffectCapture.swift",
    "AudioEffectChorus.swift",
    "AudioEffectCompressor.swift",
    "AudioEffectDelay.swift",
    "AudioEffectDistortion.swift",
    "AudioEffectEQ.swift",
    "AudioEffectEQ10.swift",
    "AudioEffectEQ21.swift",
    "AudioEffectEQ6.swift",
    "AudioEffectFilter.swift",
    "AudioEffectHardLimiter.swift",
    "AudioEffectHighPassFilter.swift",
    "AudioEffectHighShelfFilter.swift",
    "AudioEffectInstance.swift",
    "AudioEffectLimiter.swift",
    "AudioEffectLowPassFilter.swift",
    "AudioEffectLowShelfFilter.swift",
    "AudioEffectNotchFilter.swift",
    "AudioEffectPanner.swift",
    "AudioEffectPhaser.swift",
    "AudioEffectPitchShift.swift",
    "AudioEffectRecord.swift",
    "AudioEffectReverb.swift",
    "AudioEffectSpectrumAnalyzer.swift",
    "AudioEffectSpectrumAnalyzerInstance.swift",
    "AudioEffectStereoEnhance.swift",
    "AudioListener2D.swift",
    "AudioListener3D.swift",
    "AudioSample.swift",
    "AudioSamplePlayback.swift",
    "AudioServer.swift",
    "AudioStream.swift",
    "AudioStreamGenerator.swift",
    "AudioStreamGeneratorPlayback.swift",
    "AudioStreamInteractive.swift",
    "AudioStreamMP3.swift",
    "AudioStreamMicrophone.swift",
    "AudioStreamOggVorbis.swift",
    "AudioStreamPlayback.swift",
    "AudioStreamPlaybackInteractive.swift",
    "AudioStreamPlaybackOggVorbis.swift",
    "AudioStreamPlaybackPlaylist.swift",
    "AudioStreamPlaybackPolyphonic.swift",
    "AudioStreamPlaybackResampled.swift",
    "AudioStreamPlaybackSynchronized.swift",
    "AudioStreamPlayer.swift",
    "AudioStreamPlaylist.swift",
    "AudioStreamPolyphonic.swift",
    "AudioStreamRandomizer.swift",
    "AudioStreamSynchronized.swift",
    "AudioStreamWAV.swift",
    "BaseMaterial3D.swift",
    "BitMap.swift",
    "Bone2D.swift",
    "BoneMap.swift",
    "BoxMesh.swift",
    "ButtonGroup.swift",
    "CallbackTweener.swift",
    "Camera2D.swift",
    "CameraAttributes.swift",
    "CameraAttributesPhysical.swift",
    "CameraAttributesPractical.swift",
    "CameraFeed.swift",
    "CameraServer.swift",
    "CameraTexture.swift",
    "CanvasItem.swift",
    "CanvasItemMaterial.swift",
    "CanvasLayer.swift",
    "CanvasTexture.swift",
    "CapsuleMesh.swift",
    "CharFXTransform.swift",
    "ColorPalette.swift",
    "Compositor.swift",
    "CompositorEffect.swift",
    "CompressedCubemap.swift",
    "CompressedCubemapArray.swift",
    "CompressedTextureLayered.swift",
    "ConfigFile.swift",
    "Control.swift",
    "Crypto.swift",
    "CryptoKey.swift",
    "Cubemap.swift",
    "CubemapArray.swift",
    "Curve.swift",
    "CurveTexture.swift",
    "CurveXYZTexture.swift",
    "CylinderMesh.swift",
    "DTLSServer.swift",
    "DirAccess.swift",
    "DisplayServer.swift",
    "DisplayServerEmbedded.swift",
    "ENetConnection.swift",
    "ENetMultiplayerPeer.swift",
    "ENetPacketPeer.swift",
    "EncodedObjectAsID.swift",
    "EngineDebugger.swift",
    "EngineProfiler.swift",
    "Environment.swift",
    "Expression.swift",
    "ExternalTexture.swift",
    "FastNoiseLite.swift",
    "FileAccess.swift",
    "FogMaterial.swift",
    "Font.swift",
    "FontFile.swift",
    "FontVariation.swift",
    "FramebufferCacheRD.swift",
    "GDExtension.swift",
    "GDExtensionManager.swift",
    "GDScript.swift",
    "GodotInstance.swift",
    "Gradient.swift",
    "GradientTexture1D.swift",
    "HMACContext.swift",
    "HTTPClient.swift",
    "HTTPRequest.swift",
    "HashingContext.swift",
    "IP.swift",
    "Image.swift",
    "ImageFormatLoader.swift",
    "ImageFormatLoaderExtension.swift",
    "ImageTexture.swift",
    "ImageTextureLayered.swift",
    "ImmediateMesh.swift",
    "ImporterMesh.swift",
    "Input.swift",
    "InputEvent.swift",
    "InputEventAction.swift",
    "InputEventFromWindow.swift",
    "InputEventGesture.swift",
    "InputEventJoypadButton.swift",
    "InputEventJoypadMotion.swift",
    "InputEventKey.swift",
    "InputEventMIDI.swift",
    "InputEventMagnifyGesture.swift",
    "InputEventMouse.swift",
    "InputEventMouseButton.swift",
    "InputEventMouseMotion.swift",
    "InputEventPanGesture.swift",
    "InputEventScreenDrag.swift",
    "InputEventScreenTouch.swift",
    "InputEventShortcut.swift",
    "InputEventWithModifiers.swift",
    "InputMap.swift",
    "InstancePlaceholder.swift",
    "IntervalTweener.swift",
    "JNISingleton.swift",
    "JSON.swift",
    "JSONRPC.swift",
    "JavaClass.swift",
    "JavaClassWrapper.swift",
    "JavaObject.swift",
    "JavaScriptBridge.swift",
    "JavaScriptObject.swift",
    "LabelSettings.swift",
    "LightmapGIData.swift",
    "Lightmapper.swift",
    "LightmapperRD.swift",
    "MainLoop.swift",
    "Marshalls.swift",
    "Material.swift",
    "Mesh.swift",
    "MeshConvexDecompositionSettings.swift",
    "MeshDataTool.swift",
    "MeshLibrary.swift",
    "MeshTexture.swift",
    "MethodTweener.swift",
    "MissingNode.swift",
    "MissingResource.swift",
    "MovieWriter.swift",
    "MultiMesh.swift",
    "MultiplayerAPI.swift",
    "MultiplayerAPIExtension.swift",
    "MultiplayerPeer.swift",
    "MultiplayerPeerExtension.swift",
    "MultiplayerSpawner.swift",
    "MultiplayerSynchronizer.swift",
    "Mutex.swift",
    "NativeMenu.swift",
    "NavigationMesh.swift",
    "NavigationMeshGenerator.swift",
    "NavigationMeshSourceGeometryData2D.swift",
    "NavigationMeshSourceGeometryData3D.swift",
    "NavigationPolygon.swift",
    "Node.swift",
    "Node2D.swift",
    "Node3D.swift",
    "Node3DGizmo.swift",
    "Noise.swift",
    "OS.swift",
    "OccluderPolygon2D.swift",
    "OfflineMultiplayerPeer.swift",
    "OggPacketSequence.swift",
    "OggPacketSequencePlayback.swift",
    "OptimizedTranslation.swift",
    "PCKPacker.swift",
    "PackedDataContainer.swift",
    "PackedDataContainerRef.swift",
    "PackedScene.swift",
    "PacketPeer.swift",
    "PacketPeerDTLS.swift",
    "PacketPeerExtension.swift",
    "PacketPeerStream.swift",
    "PacketPeerUDP.swift",
    "PanoramaSkyMaterial.swift",
    "ParallaxBackground.swift",
    "ParticleProcessMaterial.swift",
    "Performance.swift",
    "PhysicalSkyMaterial.swift",
    "PhysicsDirectBodyState2D.swift",
    "PhysicsDirectBodyState2DExtension.swift",
    "PhysicsDirectBodyState3D.swift",
    "PhysicsDirectBodyState3DExtension.swift",
    "PhysicsDirectSpaceState2D.swift",
    "PhysicsDirectSpaceState2DExtension.swift",
    "PhysicsDirectSpaceState3D.swift",
    "PhysicsDirectSpaceState3DExtension.swift",
    "PhysicsMaterial.swift",
    "PhysicsPointQueryParameters2D.swift",
    "PhysicsPointQueryParameters3D.swift",
    "PhysicsRayQueryParameters2D.swift",
    "PhysicsRayQueryParameters3D.swift",
    "PhysicsServer2D.swift",
    "PhysicsServer2DExtension.swift",
    "PhysicsServer2DManager.swift",
    "PhysicsServer3D.swift",
    "PhysicsServer3DExtension.swift",
    "PhysicsServer3DManager.swift",
    "PhysicsServer3DRenderingServerHandler.swift",
    "PhysicsShapeQueryParameters2D.swift",
    "PhysicsShapeQueryParameters3D.swift",
    "PhysicsTestMotionParameters2D.swift",
    "PhysicsTestMotionParameters3D.swift",
    "PhysicsTestMotionResult2D.swift",
    "PhysicsTestMotionResult3D.swift",
    "PlaceholderCubemap.swift",
    "PlaceholderCubemapArray.swift",
    "PlaceholderMaterial.swift",
    "PlaceholderMesh.swift",
    "PlaceholderTextureLayered.swift",
    "PlaneMesh.swift",
    "PointMesh.swift",
    "PolygonPathFinder.swift",
    "Popup.swift",
    "PopupMenu.swift",
    "PopupPanel.swift",
    "PrimitiveMesh.swift",
    "PrismMesh.swift",
    "ProceduralSkyMaterial.swift",
    "ProjectSettings.swift",
    "PropertyTweener.swift",
    "QuadMesh.swift",
    "RDAttachmentFormat.swift",
    "RDFramebufferPass.swift",
    "RDPipelineColorBlendState.swift",
    "RDPipelineColorBlendStateAttachment.swift",
    "RDPipelineDepthStencilState.swift",
    "RDPipelineMultisampleState.swift",
    "RDPipelineRasterizationState.swift",
    "RDPipelineSpecializationConstant.swift",
    "RDSamplerState.swift",
    "RDShaderFile.swift",
    "RDShaderSPIRV.swift",
    "RDShaderSource.swift",
    "RDTextureFormat.swift",
    "RDTextureView.swift",
    "RDUniform.swift",
    "RDVertexAttribute.swift",
    "RandomNumberGenerator.swift",
    "RegEx.swift",
    "RegExMatch.swift",
    "RenderData.swift",
    "RenderDataExtension.swift",
    "RenderDataRD.swift",
    "RenderSceneBuffers.swift",
    "RenderSceneBuffersConfiguration.swift",
    "RenderSceneBuffersExtension.swift",
    "RenderSceneBuffersRD.swift",
    "RenderSceneData.swift",
    "RenderSceneDataExtension.swift",
    "RenderSceneDataRD.swift",
    "RenderingDevice.swift",
    "RenderingNativeSurface.swift",
    "RenderingNativeSurfaceApple.swift",
    "RenderingNativeSurfaceVulkan.swift",
    "RenderingServer.swift",
    "Resource.swift",
    "ResourceFormatLoader.swift",
    "ResourceFormatSaver.swift",
    "ResourceImporter.swift",
    "ResourceImporterBMFont.swift",
    "ResourceImporterBitMap.swift",
    "ResourceImporterCSVTranslation.swift",
    "ResourceImporterDynamicFont.swift",
    "ResourceImporterImage.swift",
    "ResourceImporterImageFont.swift",
    "ResourceImporterLayeredTexture.swift",
    "ResourceImporterMP3.swift",
    "ResourceImporterOBJ.swift",
    "ResourceImporterOggVorbis.swift",
    "ResourceImporterScene.swift",
    "ResourceImporterShaderFile.swift",
    "ResourceImporterTexture.swift",
    "ResourceImporterTextureAtlas.swift",
    "ResourceImporterWAV.swift",
    "ResourceLoader.swift",
    "ResourcePreloader.swift",
    "ResourceSaver.swift",
    "ResourceUID.swift",
    "RibbonTrailMesh.swift",
    "RichTextEffect.swift",
    "SceneMultiplayer.swift",
    "SceneReplicationConfig.swift",
    "SceneState.swift",
    "SceneTree.swift",
    "SceneTreeTimer.swift",
    "Script.swift",
    "ScriptExtension.swift",
    "ScriptLanguage.swift",
    "ScriptLanguageExtension.swift",
    "Semaphore.swift",
    "Shader.swift",
    "ShaderGlobalsOverride.swift",
    "ShaderInclude.swift",
    "ShaderIncludeDB.swift",
    "ShaderMaterial.swift",
    "Shape3D.swift",
    "Shortcut.swift",
    "Skeleton2D.swift",
    "SkeletonModification2D.swift",
    "SkeletonModificationStack2D.swift",
    "SkeletonProfile.swift",
    "SkeletonProfileHumanoid.swift",
    "Skin.swift",
    "SkinReference.swift",
    "Sky.swift",
    "SphereMesh.swift",
    "SpriteFrames.swift",
    "StandardMaterial3D.swift",
    "StatusIndicator.swift",
    "StreamPeer.swift",
    "StreamPeerBuffer.swift",
    "StreamPeerExtension.swift",
    "StreamPeerGZIP.swift",
    "StreamPeerTCP.swift",
    "StreamPeerTLS.swift",
    "StyleBox.swift",
    "StyleBoxEmpty.swift",
    "StyleBoxFlat.swift",
    "StyleBoxLine.swift",
    "StyleBoxTexture.swift",
    "SubViewport.swift",
    "SubtweenTweener.swift",
    "SurfaceTool.swift",
    "SystemFont.swift",
    "TCPServer.swift",
    "TLSOptions.swift",
    "TextLine.swift",
    "TextMesh.swift",
    "TextParagraph.swift",
    "TextServer.swift",
    "TextServerAdvanced.swift",
    "TextServerDummy.swift",
    "TextServerExtension.swift",
    "TextServerManager.swift",
    "Texture.swift",
    "Texture2D.swift",
    "TextureCubemapArrayRD.swift",
    "TextureCubemapRD.swift",
    "TextureLayered.swift",
    "TextureLayeredRD.swift",
    "Theme.swift",
    "ThemeDB.swift",
    "Thread.swift",
    "TileData.swift",
    "TileMapPattern.swift",
    "TileSet.swift",
    "TileSetAtlasSource.swift",
    "TileSetScenesCollectionSource.swift",
    "TileSetSource.swift",
    "Time.swift",
    "Timer.swift",
    "TorusMesh.swift",
    "Translation.swift",
    "TranslationDomain.swift",
    "TranslationServer.swift",
    "TriangleMesh.swift",
    "TubeTrailMesh.swift",
    "Tween.swift",
    "Tweener.swift",
    "UDPServer.swift",
    "UPNP.swift",
    "UPNPDevice.swift",
    "UndoRedo.swift",
    "UniformSetCacheRD.swift",
    "VideoStream.swift",
    "VideoStreamPlayback.swift",
    "VideoStreamTheora.swift",
    "Viewport.swift",
    "ViewportTexture.swift",
    "VisualShader.swift",
    "VisualShaderNode.swift",
    "VisualShaderNodeCustom.swift",
    "VoxelGIData.swift",
    "WeakRef.swift",
    "WebRTCDataChannel.swift",
    "WebRTCDataChannelExtension.swift",
    "WebRTCMultiplayerPeer.swift",
    "WebRTCPeerConnection.swift",
    "WebRTCPeerConnectionExtension.swift",
    "WebSocketMultiplayerPeer.swift",
    "WebSocketPeer.swift",
    "Window.swift",
    "WorkerThreadPool.swift",
    "World2D.swift",
    "World3D.swift",
    "WorldEnvironment.swift",
    "X509Certificate.swift",
    "XMLParser.swift",
    "ZIPPacker.swift",
    "ZIPReader.swift",
]

let gltf: [String] = [
    "FBXDocument.swift",
    "FBXState.swift",
    "GLTFAccessor.swift",
    "GLTFAnimation.swift",
    "GLTFBufferView.swift",
    "GLTFCamera.swift",
    "GLTFDocument.swift",
    "GLTFDocumentExtension.swift",
    "GLTFDocumentExtensionConvertImporterMesh.swift",
    "GLTFLight.swift",
    "GLTFMesh.swift",
    "GLTFNode.swift",
    "GLTFObjectModelProperty.swift",
    "GLTFPhysicsBody.swift",
    "GLTFPhysicsShape.swift",
    "GLTFSkeleton.swift",
    "GLTFSkin.swift",
    "GLTFSpecGloss.swift",
    "GLTFState.swift",
    "GLTFTexture.swift",
    "GLTFTextureSampler.swift",

]

let twoD: [String] = [
    "AStar2D.swift",
    "AStarGrid2D.swift",
    "AnimatableBody2D.swift",
    "AnimatedSprite2D.swift",
    "AnimationNodeBlendSpace2D.swift",
    "Area2D.swift",
    "AudioStreamPlayer2D.swift",
    "BackBufferCopy.swift",
    "CPUParticles2D.swift",
    "CanvasGroup.swift",
    "CanvasModulate.swift",
    "CapsuleShape2D.swift",
    "CharacterBody2D.swift",
    "CircleShape2D.swift",
    "CollisionObject2D.swift",
    "CollisionPolygon2D.swift",
    "CollisionShape2D.swift",
    "CompressedTexture2D.swift",
    "CompressedTexture2DArray.swift",
    "ConcavePolygonShape2D.swift",
    "ConvexPolygonShape2D.swift",
    "Curve2D.swift",
    "DampedSpringJoint2D.swift",
    "DirectionalLight2D.swift",
    "GPUParticles2D.swift",
    "Geometry2D.swift",
    "GradientTexture2D.swift",
    "GrooveJoint2D.swift",
    "Joint2D.swift",
    "KinematicCollision2D.swift",
    "Light2D.swift",
    "LightOccluder2D.swift",
    "Line2D.swift",
    "Marker2D.swift",
    "MeshInstance2D.swift",
    "MultiMeshInstance2D.swift",
    "NavigationAgent2D.swift",
    "NavigationLink2D.swift",
    "NavigationObstacle2D.swift",
    "NavigationPathQueryParameters2D.swift",
    "NavigationPathQueryResult2D.swift",
    "NavigationRegion2D.swift",
    "NavigationServer2D.swift",
    "NoiseTexture2D.swift",
    "Parallax2D.swift",
    "ParallaxLayer.swift",
    "Path2D.swift",
    "PathFollow2D.swift",
    "PhysicalBone2D.swift",
    "PhysicsBody2D.swift",
    "PinJoint2D.swift",
    "PlaceholderTexture2D.swift",
    "PlaceholderTexture2DArray.swift",
    "PointLight2D.swift",
    "Polygon2D.swift",
    "PortableCompressedTexture2D.swift",
    "RayCast2D.swift",
    "RectangleShape2D.swift",
    "RemoteTransform2D.swift",
    "RigidBody2D.swift",
    "SegmentShape2D.swift",
    "SeparationRayShape2D.swift",
    "Shape2D.swift",
    "ShapeCast2D.swift",
    "SkeletonModification2DCCDIK.swift",
    "SkeletonModification2DFABRIK.swift",
    "SkeletonModification2DJiggle.swift",
    "SkeletonModification2DLookAt.swift",
    "SkeletonModification2DPhysicalBones.swift",
    "SkeletonModification2DStackHolder.swift",
    "SkeletonModification2DTwoBoneIK.swift",
    "Sprite2D.swift",
    "StaticBody2D.swift",
    "Texture2DArray.swift",
    "Texture2DArrayRD.swift",
    "Texture2DRD.swift",
    "TileMap.swift",
    "TileMapLayer.swift",
    "TouchScreenButton.swift",
    "VisibleOnScreenEnabler2D.swift",
    "VisibleOnScreenNotifier2D.swift",
    "WorldBoundaryShape2D.swift",
]

let threeD: [String] = [
    "AStar3D.swift",
    "AnimatableBody3D.swift",
    "AnimatedSprite3D.swift",
    "Area3D.swift",
    "ArrayOccluder3D.swift",
    "AudioStreamPlayer3D.swift",
    "BoneAttachment3D.swift",
    "BoxOccluder3D.swift",
    "BoxShape3D.swift",
    "CPUParticles3D.swift",
    "CSGBox3D.swift",
    "CSGCombiner3D.swift",
    "CSGCylinder3D.swift",
    "CSGMesh3D.swift",
    "CSGPolygon3D.swift",
    "CSGPrimitive3D.swift",
    "CSGShape3D.swift",
    "CSGSphere3D.swift",
    "CSGTorus3D.swift",
    "Camera3D.swift",
    "CapsuleShape3D.swift",
    "CharacterBody3D.swift",
    "CollisionObject3D.swift",
    "CollisionPolygon3D.swift",
    "CollisionShape3D.swift",
    "CompressedTexture3D.swift",
    "ConcavePolygonShape3D.swift",
    "ConeTwistJoint3D.swift",
    "ConvexPolygonShape3D.swift",
    "Curve3D.swift",
    "CylinderShape3D.swift",
    "Decal.swift",
    "DirectionalLight3D.swift",
    "FogVolume.swift",
    "GPUParticles3D.swift",
    "GPUParticlesAttractor3D.swift",
    "GPUParticlesAttractorBox3D.swift",
    "GPUParticlesAttractorSphere3D.swift",
    "GPUParticlesAttractorVectorField3D.swift",
    "GPUParticlesCollision3D.swift",
    "GPUParticlesCollisionBox3D.swift",
    "GPUParticlesCollisionHeightField3D.swift",
    "GPUParticlesCollisionSDF3D.swift",
    "GPUParticlesCollisionSphere3D.swift",
    "Generic6DOFJoint3D.swift",
    "Geometry3D.swift",
    "GeometryInstance3D.swift",
    "GridMap.swift",
    "HeightMapShape3D.swift",
    "HingeJoint3D.swift",
    "ImageTexture3D.swift",
    "ImporterMeshInstance3D.swift",
    "Joint3D.swift",
    "KinematicCollision3D.swift",
    "Label3D.swift",
    "Light3D.swift",
    "LightmapGI.swift",
    "LightmapProbe.swift",
    "LookAtModifier3D.swift",
    "Marker3D.swift",
    "MeshInstance3D.swift",
    "MultiMeshInstance3D.swift",
    "NavigationAgent3D.swift",
    "NavigationLink3D.swift",
    "NavigationObstacle3D.swift",
    "NavigationPathQueryParameters3D.swift",
    "NavigationPathQueryResult3D.swift",
    "NavigationRegion3D.swift",
    "NavigationServer3D.swift",
    "NoiseTexture3D.swift",
    "ORMMaterial3D.swift",
    "Occluder3D.swift",
    "OccluderInstance3D.swift",
    "OmniLight3D.swift",
    "Path3D.swift",
    "PathFollow3D.swift",
    "PhysicalBone3D.swift",
    "PhysicalBoneSimulator3D.swift",
    "PhysicsBody3D.swift",
    "PinJoint3D.swift",
    "PlaceholderTexture3D.swift",
    "PolygonOccluder3D.swift",
    "QuadOccluder3D.swift",
    "RayCast3D.swift",
    "ReflectionProbe.swift",
    "RemoteTransform3D.swift",
    "RetargetModifier3D.swift",
    "RigidBody3D.swift",
    "RootMotionView.swift",
    "SeparationRayShape3D.swift",
    "ShapeCast3D.swift",
    "Skeleton3D.swift",
    "SkeletonIK3D.swift",
    "SkeletonModifier3D.swift",
    "SliderJoint3D.swift",
    "SoftBody3D.swift",
    "SphereOccluder3D.swift",
    "SphereShape3D.swift",
    "SpotLight3D.swift",
    "SpringArm3D.swift",
    "SpringBoneCollision3D.swift",
    "SpringBoneCollisionCapsule3D.swift",
    "SpringBoneCollisionPlane3D.swift",
    "SpringBoneCollisionSphere3D.swift",
    "SpringBoneSimulator3D.swift",
    "Sprite3D.swift",
    "SpriteBase3D.swift",
    "StaticBody3D.swift",
    "Texture3D.swift",
    "Texture3DRD.swift",
    "VehicleBody3D.swift",
    "VehicleWheel3D.swift",
    "VisibleOnScreenEnabler3D.swift",
    "VisibleOnScreenNotifier3D.swift",
    "VisualInstance3D.swift",
    "VoxelGI.swift",
    "WorldBoundaryShape3D.swift",
]

let controls: [String] = [
    "AcceptDialog.swift",
    "AspectRatioContainer.swift",
    "BaseButton.swift",
    "BoxContainer.swift",
    "Button.swift",
    "CenterContainer.swift",
    "CheckBox.swift",
    "CheckButton.swift",
    "ConfirmationDialog.swift",
    "CodeEdit.swift",
    "CodeHighlighter.swift",
    "ColorPicker.swift",
    "ColorPickerButton.swift",
    "ColorRect.swift",
    "Container.swift",
    "FileDialog.swift",
    "FileSystemDock.swift",
    "FlowContainer.swift",
    "GraphEdit.swift",
    "GraphElement.swift",
    "GraphFrame.swift",
    "GraphNode.swift",
    "GridContainer.swift",
    "HBoxContainer.swift",
    "HFlowContainer.swift",
    "HScrollBar.swift",
    "HSeparator.swift",
    "HSlider.swift",
    "HSplitContainer.swift",
    "ItemList.swift",
    "Label.swift",
    "LineEdit.swift",
    "LinkButton.swift",
    "MarginContainer.swift",
    "MenuBar.swift",
    "MenuButton.swift",
    "NinePatchRect.swift",
    "OptionButton.swift",
    "Panel.swift",
    "PanelContainer.swift",
    "ProgressBar.swift",
    "Range.swift",
    "ReferenceRect.swift",
    "RichTextLabel.swift",
    "ScrollBar.swift",
    "ScrollContainer.swift",
    "Separator.swift",
    "Slider.swift",
    "SpinBox.swift",
    "SplitContainer.swift",
    "SubViewportContainer.swift",
    "SyntaxHighlighter.swift",
    "TabBar.swift",
    "TabContainer.swift",
    "TextEdit.swift",
    "TextureButton.swift",
    "TextureProgressBar.swift",
    "TextureRect.swift",
    "Tree.swift",
    "TreeItem.swift",
    "VBoxContainer.swift",
    "VFlowContainer.swift",
    "VScrollBar.swift",
    "VSeparator.swift",
    "VSlider.swift",
    "VSplitContainer.swift",
    "VideoStreamPlayer.swift",
]

let xr: [String] = [
    "MobileVRInterface.swift",
    "OpenXRAPIExtension.swift",
    "OpenXRAction.swift",
    "OpenXRActionBindingModifier.swift",
    "OpenXRActionMap.swift",
    "OpenXRActionSet.swift",
    "OpenXRAnalogThresholdModifier.swift",
    "OpenXRBindingModifier.swift",
    "OpenXRCompositionLayer.swift",
    "OpenXRCompositionLayerCylinder.swift",
    "OpenXRCompositionLayerEquirect.swift",
    "OpenXRCompositionLayerQuad.swift",
    "OpenXRDpadBindingModifier.swift",
    "OpenXRExtensionWrapperExtension.swift",
    
    "OpenXRHand.swift",
    "OpenXRHapticBase.swift",
    "OpenXRHapticVibration.swift",
    "OpenXRIPBinding.swift",
    "OpenXRIPBindingModifier.swift",
    "OpenXRInteractionProfile.swift",
    "OpenXRInteractionProfileMetadata.swift",
    "OpenXRInterface.swift",
    "OpenXRVisibilityMask.swift",
    "WebXRInterface.swift",
    "XRAnchor3D.swift",
    "XRBodyModifier3D.swift",
    "XRBodyTracker.swift",
    "XRCamera3D.swift",
    "XRController3D.swift",
    "XRControllerTracker.swift",
    "XRFaceModifier3D.swift",
    "XRFaceTracker.swift",
    "XRHandModifier3D.swift",
    "XRHandTracker.swift",
    "XRInterface.swift",
    "XRInterfaceExtension.swift",
    "XRNode3D.swift",
    "XROrigin3D.swift",
    "XRPose.swift",
    "XRPositionalTracker.swift",
    "XRServer.swift",
    "XRTracker.swift",
    "XRVRS.swift",
]

let visualShaderNodes: [String] = [
    "VisualShaderNodeBillboard.swift",
    "VisualShaderNodeBooleanConstant.swift",
    "VisualShaderNodeBooleanParameter.swift",
    "VisualShaderNodeClamp.swift",
    "VisualShaderNodeColorConstant.swift",
    "VisualShaderNodeColorFunc.swift",
    "VisualShaderNodeColorOp.swift",
    "VisualShaderNodeColorParameter.swift",
    "VisualShaderNodeComment.swift",
    "VisualShaderNodeCompare.swift",
    "VisualShaderNodeConstant.swift",
    "VisualShaderNodeCubemap.swift",
    "VisualShaderNodeCubemapParameter.swift",
    "VisualShaderNodeCurveTexture.swift",
    "VisualShaderNodeCurveXYZTexture.swift",
    "VisualShaderNodeDerivativeFunc.swift",
    "VisualShaderNodeDeterminant.swift",
    "VisualShaderNodeDistanceFade.swift",
    "VisualShaderNodeDotProduct.swift",
    "VisualShaderNodeExpression.swift",
    "VisualShaderNodeFaceForward.swift",
    "VisualShaderNodeFloatConstant.swift",
    "VisualShaderNodeFloatFunc.swift",
    "VisualShaderNodeFloatOp.swift",
    "VisualShaderNodeFloatParameter.swift",
    "VisualShaderNodeFrame.swift",
    "VisualShaderNodeFresnel.swift",
    "VisualShaderNodeGlobalExpression.swift",
    "VisualShaderNodeGroupBase.swift",
    "VisualShaderNodeIf.swift",
    "VisualShaderNodeInput.swift",
    "VisualShaderNodeIntConstant.swift",
    "VisualShaderNodeIntFunc.swift",
    "VisualShaderNodeIntOp.swift",
    "VisualShaderNodeIntParameter.swift",
    "VisualShaderNodeIs.swift",
    "VisualShaderNodeLinearSceneDepth.swift",
    "VisualShaderNodeMix.swift",
    "VisualShaderNodeMultiplyAdd.swift",
    "VisualShaderNodeOuterProduct.swift",
    "VisualShaderNodeOutput.swift",
    "VisualShaderNodeParameter.swift",
    "VisualShaderNodeParameterRef.swift",
    "VisualShaderNodeParticleAccelerator.swift",
    "VisualShaderNodeParticleBoxEmitter.swift",
    "VisualShaderNodeParticleConeVelocity.swift",
    "VisualShaderNodeParticleEmit.swift",
    "VisualShaderNodeParticleEmitter.swift",
    "VisualShaderNodeParticleMeshEmitter.swift",
    "VisualShaderNodeParticleMultiplyByAxisAngle.swift",
    "VisualShaderNodeParticleOutput.swift",
    "VisualShaderNodeParticleRandomness.swift",
    "VisualShaderNodeParticleRingEmitter.swift",
    "VisualShaderNodeParticleSphereEmitter.swift",
    "VisualShaderNodeProximityFade.swift",
    "VisualShaderNodeRandomRange.swift",
    "VisualShaderNodeRemap.swift",
    "VisualShaderNodeReroute.swift",
    "VisualShaderNodeResizableBase.swift",
    "VisualShaderNodeRotationByAxis.swift",
    "VisualShaderNodeSDFRaymarch.swift",
    "VisualShaderNodeSDFToScreenUV.swift",
    "VisualShaderNodeSample3D.swift",
    "VisualShaderNodeScreenNormalWorldSpace.swift",
    "VisualShaderNodeScreenUVToSDF.swift",
    "VisualShaderNodeSmoothStep.swift",
    "VisualShaderNodeStep.swift",
    "VisualShaderNodeSwitch.swift",
    "VisualShaderNodeTexture.swift",
    "VisualShaderNodeTexture2DArray.swift",
    "VisualShaderNodeTexture2DArrayParameter.swift",
    "VisualShaderNodeTexture2DParameter.swift",
    "VisualShaderNodeTexture3D.swift",
    "VisualShaderNodeTexture3DParameter.swift",
    "VisualShaderNodeTextureParameter.swift",
    "VisualShaderNodeTextureParameterTriplanar.swift",
    "VisualShaderNodeTextureSDF.swift",
    "VisualShaderNodeTextureSDFNormal.swift",
    "VisualShaderNodeTransformCompose.swift",
    "VisualShaderNodeTransformConstant.swift",
    "VisualShaderNodeTransformDecompose.swift",
    "VisualShaderNodeTransformFunc.swift",
    "VisualShaderNodeTransformOp.swift",
    "VisualShaderNodeTransformParameter.swift",
    "VisualShaderNodeTransformVecMult.swift",
    "VisualShaderNodeUIntConstant.swift",
    "VisualShaderNodeUIntFunc.swift",
    "VisualShaderNodeUIntOp.swift",
    "VisualShaderNodeUIntParameter.swift",
    "VisualShaderNodeUVFunc.swift",
    "VisualShaderNodeUVPolarCoord.swift",
    "VisualShaderNodeVarying.swift",
    "VisualShaderNodeVaryingGetter.swift",
    "VisualShaderNodeVaryingSetter.swift",
    "VisualShaderNodeVec2Constant.swift",
    "VisualShaderNodeVec2Parameter.swift",
    "VisualShaderNodeVec3Constant.swift",
    "VisualShaderNodeVec3Parameter.swift",
    "VisualShaderNodeVec4Constant.swift",
    "VisualShaderNodeVec4Parameter.swift",
    "VisualShaderNodeVectorBase.swift",
    "VisualShaderNodeVectorCompose.swift",
    "VisualShaderNodeVectorDecompose.swift",
    "VisualShaderNodeVectorDistance.swift",
    "VisualShaderNodeVectorFunc.swift",
    "VisualShaderNodeVectorLen.swift",
    "VisualShaderNodeVectorOp.swift",
    "VisualShaderNodeVectorRefract.swift",
    "VisualShaderNodeWorldPositionFromDepth.swift",
]

let editor: [String] = [
    "EditorCommandPalette.swift",
    "EditorContextMenuPlugin.swift",
    "EditorDebuggerPlugin.swift",
    "EditorDebuggerSession.swift",
    "EditorExportPlatform.swift",
    "EditorExportPlatformAndroid.swift",
    "EditorExportPlatformExtension.swift",
    "EditorExportPlatformIOS.swift",
    "EditorExportPlatformLinuxBSD.swift",
    "EditorExportPlatformMacOS.swift",
    "EditorExportPlatformPC.swift",
    "EditorExportPlatformWeb.swift",
    "EditorExportPlatformWindows.swift",
    "EditorExportPlugin.swift",
    "EditorExportPreset.swift",
    "EditorFeatureProfile.swift",
    "EditorFileDialog.swift",
    "EditorFileSystem.swift",
    "EditorFileSystemDirectory.swift",
    "EditorFileSystemImportFormatSupportQuery.swift",
    "EditorImportPlugin.swift",
    "EditorInspector.swift",
    "EditorInspectorPlugin.swift",
    "EditorInterface.swift",
    "EditorNode3DGizmo.swift",
    "EditorNode3DGizmoPlugin.swift",
    "EditorPaths.swift",
    "EditorPlugin.swift",
    "EditorProperty.swift",
    "EditorResourceConversionPlugin.swift",
    "EditorResourcePicker.swift",
    "EditorResourcePreview.swift",
    "EditorResourcePreviewGenerator.swift",
    "EditorResourceTooltipPlugin.swift",
    "EditorSceneFormatImporter.swift",
    "EditorSceneFormatImporterBlend.swift",
    "EditorSceneFormatImporterFBX2GLTF.swift",
    "EditorSceneFormatImporterGLTF.swift",
    "EditorSceneFormatImporterUFBX.swift",
    "EditorScenePostImport.swift",
    "EditorScenePostImportPlugin.swift",
    "EditorScript.swift",
    "EditorScriptPicker.swift",
    "EditorSelection.swift",
    "EditorSettings.swift",
    "EditorSpinSlider.swift",
    "EditorSyntaxHighlighter.swift",
    "EditorToaster.swift",
    "EditorTranslationParserPlugin.swift",
    "EditorUndoRedoManager.swift",
    "EditorVCSInterface.swift",
    "GDScriptSyntaxHighlighter.swift",
    "GridMapEditorPlugin.swift",
    "OpenXRInteractionProfileEditor.swift",
    "OpenXRInteractionProfileEditorBase.swift",
    "ScriptCreateDialog.swift",
    "ScriptEditor.swift",
    "ScriptEditorBase.swift",
    "OpenXRBindingModifierEditor.swift",
]

extension URL {
    func appending(_ paths: [String]) -> URL {
        return paths.reduce(self) { $0.appending(path: $1) }
    }
}
