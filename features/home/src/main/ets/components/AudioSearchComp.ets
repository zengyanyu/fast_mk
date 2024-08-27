import { KeyboardAvoidMode, window } from '@kit.ArkUI';
import { audio } from '@kit.AudioKit';
import { speechRecognizer } from '@kit.CoreSpeechKit';
import { permissionPlugin } from '@mk/basic';


export enum VoiceState {
  DEFAULT,
  VOICING,
  VOICEOVER
}

@Component
export struct AudioSearchComp {
  @State voiceState: VoiceState = VoiceState.DEFAULT
  keyword: string = ''
  audioCapturer: audio.AudioCapturer | null = null
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  // 语音识别的会话 ID
  sessionId: string = '123456';
  onChange: (keyword: string) => void = () => {
  }
  onComplete: (keyword: string) => void = () => {
  }

  async startRecord() {
    // 语音 01 - 创建识别对象 保存到 组件属性中

    // 创建引擎，通过callback形式返回
    // 设置创建引擎参数
    // 调用createEngine方法
    this.asrEngine = await speechRecognizer.createEngine({
      language: 'zh-CN',
      online: 1,
      extraParams: { "locate": "CN", "recognizerMode": "short" }
    });

    // 语音 02 - 设置识别之后的回调函数
    // 创建回调对象
    let setListener: speechRecognizer.RecognitionListener = {
      // 开始识别成功回调
      onStart(sessionId: string, eventMessage: string) {
        // Logger.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // 事件回调
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        // Logger.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },

      // 识别结果回调，包括中间结果和最终结果
      // 箭头函数 的 this 会在创建时，绑定 当前所在作用域中的 this(当前组件)
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        // Logger.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
        // Logger.info(result.result)
        // 保存 识别的结果
        this.keyword = result.result
        // 通知 父组件
        this.onChange(this.keyword)
      },
      // 识别完成回调
      // 箭头函数 的 this 会在创建时，绑定 当前所在作用域中的 this(当前组件)
      onComplete: (sessionId: string, eventMessage: string) => {
        // Logger.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
        this.onComplete(this.keyword)
        this.keyword = ''
      },
      // 错误回调，错误码通过本方法返回
      // 如：返回错误码1002200006，识别引擎正忙，引擎正在识别中
      // 更多错误码请参考错误码参考
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        // Logger.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    }
    // 设置回调
    this.asrEngine.setListener(setListener);

    // 语音 03 - 设置识别参数 开始识别
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      // 识别的语音的信息
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: { "vadBegin": 2000, "vadEnd": 3000, "maxAudioDuration": 40000 }
    };
    // 调用开始识别方法
    this.asrEngine.startListening(recognizerParams);

    // ---------- 下面是录音相关的逻辑  ----------
    // 录音 01 - 创建 录音 实例对象
    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
        channels: audio.AudioChannel.CHANNEL_1, // 通道
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
    };

    // 调用 createAudioCapturer 创建 录音用的实例对象
    this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions)

    // 录音 02 监听录制的结果并 做一些事情

    // 回调函数中，将录制的音频信息，保存到  cacheDir 中
    this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
      // 语音04 - 写入音频留
      // 写入的音频流，转手传递给 识别引擎
      this.asrEngine?.writeAudio(this.sessionId, new Uint8Array(buffer));
      // Logger.info('readData 触发啦~~~')
    });

    // 录音 03 - 开启录制
    await this.audioCapturer.start();
  }

  async closeRecord() {
    // 录音 04 关闭 + 销毁
    this.audioCapturer?.stop()
    this.audioCapturer?.release()

    // 语音 05 关闭+释放
    this.asrEngine?.finish(this.sessionId)
    this.asrEngine?.shutdown()


    this.voiceState = VoiceState.VOICEOVER
  }

  aboutToAppear(): void {
    permissionPlugin.requestPermissions(['ohos.permission.MICROPHONE'])
      .then(() => {
        window.getLastWindow(getContext())
          .then(win => {
            // 键盘避让
            win.getUIContext()
              .setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)
          })
      })

  }

  build() {
    Column() {
      if (this.voiceState !== VoiceState.DEFAULT) {
        Column({ space: 16 }) {
          if (this.voiceState === VoiceState.VOICING) {
            Text('请说，我在聆听...')
              .fontSize(14)
          } else if (this.voiceState === VoiceState.VOICEOVER && this.keyword === '') {
            Text('未检测到语音，请长按按钮重试')
              .fontSize(14)
          }
          Text() {
            Span('你可以这样说：')
            Span('太阳眼镜/冬款连衣裙')
              .fontColor($r('[basic].color.gray'))
          }
          .fontSize(12)
        }
        .justifyContent(FlexAlign.Center)
        .height(150)
      }
      Blank()
      Button() {
        Row({ space: 4 }) {
          Image($r('sys.media.ohos_ic_public_voice'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
          if (this.voiceState === VoiceState.VOICING) {
            Text('松开立即搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))
          } else {
            Text('长按语音搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))
          }
        }
      }
      .padding({ left: 12, right: 12 })
      .height(36)
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })
      .margin({ bottom: 16 })
      .gesture(LongPressGesture()
        .onAction(() => {
          this.startRecord()
        })
        .onActionEnd(() => {
          this.closeRecord()
        })
        .onActionCancel(() => {
          this.closeRecord()
        }))

    }
    .layoutWeight(1)
    .width('100%')
    .backgroundImage($r('app.media.search_bg'))
    .backgroundImageSize(ImageSize.Contain)
    .backgroundImagePosition(Alignment.Bottom)
    .onVisibleAreaChange([0, 1], () => {
      this.keyword = ''
      this.voiceState = VoiceState.DEFAULT
    })
  }
}