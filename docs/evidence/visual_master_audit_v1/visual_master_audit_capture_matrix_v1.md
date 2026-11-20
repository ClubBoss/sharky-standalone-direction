# Visual Master Audit Capture Matrix v1

Final candidate: `bc3214e5a31ac4d10dd1c17fbde0b4c3617b4381`
Native workflow run: `30408676764`
Unified artifact: `sharky-native-visual-audit-repaired-bc3214e5a31ac4d10dd1c17fbde0b4c3617b4381`

This supersedes all prior widget-test contact sheets. The 54 source PNGs remain in the GitHub Actions artifact; only derived native-only contact sheets are committed here.

## Pre-dispatch and artifact gates

- total rows: `54`
- distribution: `canonical/none: 20; compact/none: 14; canonical/text_scale_1_4: 10; canonical/reduced_motion: 6; large/none: 4`
- unique `(state, device_profile, modifier)`: `54`
- all row candidate SHAs: final candidate
- capture source: `NATIVE_IOS_SIMULATOR` only
- `lesson.completion` and `completion.world`: separate states
- `large + reduced_motion`: absent

## Rows

| State | Profile | Modifier | Simulator | iOS runtime | PNG SHA-256 |
| --- | --- | --- | --- | --- | --- |
| placement | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `a47a82db992a76fb9dbfc81cc3540398c5ff6ebb8f3c3e1985c878eb90f40db5` |
| welcome | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `2e5502240e8a50ea14bdde500a7139e55970eed4d5b5e38d488786e6db9ddb3e` |
| home | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `e7b6ef353af482c5e1657257a48d529a23776c2187dee20986dd98f5116670f6` |
| learn | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `6399efe7207af951a801b4f3d51894aaedca6d54f0d47756c88fe49838a38148` |
| theory | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `1e51a5bd4b729617e6956e4f4b509f1fbc3a81edca669b8501874943023ac6d4` |
| table_read | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `b6f738a74e1720c797fca7a7d8e2298594cf9c80bdfa498129bbed50f33e349b` |
| action_selection | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `691435356ce82db56c6affdafa4d69309c099cc13aecca5ebf063df2eb39bbd5` |
| vrt02 | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `46d5cea84813c12af8800598719a756c04cc5340184d3b870f855899bc5985cf` |
| vrt02_correct | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `ad59ff3b53c76e579203f96f46a0de1b901fc4220135e6cf4c15cd71efbe055d` |
| vrt02_incorrect | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `09397527c78c39e63b5f703b41f097c2d2254acffd62173d77d4ccc51f845d68` |
| repair_focus | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `ae900b636aabb3da1c132fb92a038ffba1d9f7453705a1d1e453a84e01346709` |
| repair_recheck | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `5b936ff2b5d783fd8c9051318436a2b736a5c299d3bf33ef7a234e37acbc2438` |
| review | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `4f7ed99eff8751aa761ae67730112a9e56629b3fa586fed742757fd7c303405d` |
| profile_evidence | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `7deced3747e685df49589552b44f9cd0b57b9d4932614aab0227c845beec5d16` |
| session_summary | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `a90fd8c4d3da658481482afbbb45d62f5eb8d873b97e9ba5e9287e7d08fd83a5` |
| lesson.completion | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `a6cf7a027cf37dfafc691751a444340f2c77eb716604ec4f5153abb758f5be8d` |
| completion.world | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `836c86332e72a5cf47b64f00a9f6faf3854adcba14432476431a99683f58f9c6` |
| world3 | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `a6cf7a027cf37dfafc691751a444340f2c77eb716604ec4f5153abb758f5be8d` |
| hand_comparison | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `85659f9f1e320007fe7a1c236ab12e89f9f15e2d0b7e621a9a41ec16afb3f602` |
| showdown | canonical | none | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `7b941c6f25fab68791f13b26d4775f8b4615263a3ce9ca0198103f1acacb72d3` |
| placement | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `c1a6a4a33030644a95ebe8fe561fd8219594097605009b46f458941d0f14e068` |
| welcome | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `55984e0d4b9dd894ef5da1b10b4d9db6430def63998e04d11c47e47dbf628860` |
| home | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `e8f1734fd4ed925b7ed3c5382f9835367499783e6980939b85a9ad284f6a55f2` |
| learn | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `3d06964c86938221266022137f2d7da5e0ca81d75169c99f3b116fd563539709` |
| vrt02 | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `43e763db8edf4c8ff7ba7b5a1101f388b0c70ae616e3e14626efff329841bbf7` |
| vrt02_correct | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `84079513bc4cae3400b2f386aba5fdde3d40c7b5bc9d5bce1fefb5913f25d102` |
| vrt02_incorrect | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `d8398b2f5df1226e677c2f8912c1d1470ff35409235597b7de77e5cee59d23c7` |
| review | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `4ebfa96b18f00b67d8cc754b0267d48d36c8dfee403a01bb0a29f0888860f29b` |
| profile_evidence | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `5e789b64b7b742df77416d827dbb98bf5bfd07be745bcf2ee316cffae987cdca` |
| session_summary | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `5b79eec419b9f313102d7572d295134d7379df551db3ac241ad37c11492e050a` |
| lesson.completion | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `936825580e2e3dad1d72bbfbf2837832a48977618f1f078ca14fe8c8e469fd86` |
| completion.world | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `c1e11120b81f5fc3c1973a70981fdf8ce88b73a15d3167324c6cbda4f6c9a9f2` |
| repair_recheck | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `8c9c830e58a4cf32a3fa9cb8200e84b92f20e1521e0c42b63438b9eacc3b7346` |
| showdown | compact | none | iPhone 16e | com.apple.CoreSimulator.SimRuntime.iOS-26-2 | `5a6ce6d5756f737298d28a09d269a311233e35a856520c581b8b70886a7a980b` |
| home | large | none | iPhone 17 Pro Max | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `a2bd37129bdb208e522209198af6abceb4204506a6ee45571747eca21d7b4366` |
| vrt02 | large | none | iPhone 17 Pro Max | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `be2b226b99ca4f665fcefbb6d750b8a4f9634365cf58d023920ff19f5a9717d1` |
| profile_evidence | large | none | iPhone 17 Pro Max | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `56ecc3a9905fc1ba3dd09f395a2efb1fb0352c54d1a525e73c2c7326000bf002` |
| completion.world | large | none | iPhone 17 Pro Max | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `ce5fe0c47b716f3dd9a5a78125bf066405d82de67b7cf9cd4d75d0a163918d98` |
| home | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `cbd593ffe5851838c99b0071f2b53dd99b9303e495299a472f1d9a8db4e49204` |
| learn | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `4eef45f6f99949a6eb3d6e5dff3ae0e2e20fab4e57ebaaf1f0450c740406b22e` |
| vrt02 | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `69bae756378d84d24fcb8fd0720c26d3c7a048baab870fe18bcc689e97012481` |
| vrt02_incorrect | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `145712891a05df8a5c1a7b7fe0ab4e6f2a51d46bb7ff0c3b0f8a9cfc49a4008e` |
| theory | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `3700c780051b6b3748942a823baa137b6e916cfc9c9c9bfebda82ce4cd17a852` |
| review | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `9ca3b551a127681880bc59777206832208a4c22382d5ba42aafe3e963fa328b6` |
| profile_evidence | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `412a0a637e520504cae21db2e2f0326439d66252e80550aaa3026b11017df477` |
| session_summary | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `bfd9100ab920d35a400cbb34a88d732de5b4975fb4aa7ca7317b8f5ffeef913e` |
| lesson.completion | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `bbe178842d486a3ce8746d0a613233a83910cd29bb02ab9dba0680783514f8cf` |
| completion.world | canonical | text_scale_1_4 | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `2c3b8deb9044c609d8de9bba6330631b1b0cf5bec2d20a42d9e5234455c05e68` |
| home | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `baf2b5b69f33f6f3e56f5a6fcb200c03947f4d9bd9eedd57035a0a4881b323e4` |
| vrt02 | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `ffb32c4d1af2da61add886ead4a9ef24ed92469171660c05cfa0a95410cfd2d7` |
| vrt02_incorrect | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `6a7dd6920f017a6662ec52d08778722f4611e03210edc41c9f859902a066e9a9` |
| session_summary | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `6ded2d72b35cbc986df8696713af00359a813d7a6bd94d19b081ef663309dcce` |
| completion.world | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `109200b801a6163945634c9a6f68106c8cada88a67dd56f0c6da48d7bee5bb1c` |
| repair_recheck | canonical | reduced_motion | iPhone 17 Pro | com.apple.CoreSimulator.SimRuntime.iOS-26-4 | `604fdbf9a0ff194d172e7ef71eef5cdec4db29ccddf0aeb4fc6963ee1662d657` |
