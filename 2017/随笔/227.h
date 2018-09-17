227 Data Delivery with Drag and Drop

NSItemProvider Basics
Uniform Type Identifiers 帮助与其它app更加兼容, 提供给其它app, 接受其它app
Model Classes 与拖放功能进行良好结合
Advanced Topics 改进app



NSItemProvider Basics
    NSItemProvider 是一个 Data Promise(目标请求数据时, 源会异步向目标传输数据的承诺)

    Data promises 
    Asynchronous 
    Progress, cancellable Supported
    Drag and Drop
    UIPasteConfiguration
    UIPasteboard



Uniform Type Identifiers: 设置感兴趣的类型, 方便识别; 单一的类型, 或组合成一个对象类型 Model Classes
    One NSItemProvider = one “thing” being dragged

    Native file format — com.yourcompany.vector-drawing 
    PDF — kUTTypePDF
    PNG — kUTTypePNG
    JPG — kUTTypeJPEG

    Fidelity Order: 精度排序规范
        Internal type
        Highest fidelity common type 
        Next highest fidelity common type



Model Classes
    结合 Uniform Type Identifiers 和 NSItemProvider

协议
- <NSItemProviderWriting>  告诉别人你的类型 和 怎么转换为 NSData 用于传输; 
    NSItemProviderRepresentationVisibility // 可以设置对哪些可见: 对所有人可见; 同一个 team 可见; 仅对自己可见;

    @property NSArray<NSString *> *writableTypeIdentifiersForItemProvider; // 按精度排序

    // NSProgress 官方demo是 return nil
    - (nullable NSProgress *)loadDataWithTypeIdentifier:(NSString *)typeIdentifier // One of writableTypeIdentifiersForItemProvider
                       forItemProviderCompletionHandler:(void (^)(NSData * _Nullable data, NSError * _Nullable error))completionHandler;

    Code:  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:你的类型];
    内部框架自己实现:  itemProvider.registerDataRepresentation(forTypeIdentifier: "com.yourcompany.vector-drawing" ...) 
                    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePDF ...) 
                    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeTIFF ...)
                    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePNG ...) 
                    itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeJPEG ...)

- <NSItemProviderReading>  怎么读别人的类型  用数据创建 model class

    @property  NSArray<NSString *> *readableTypeIdentifiersForItemProvider;

    // 初始化你的对象
    + (nullable instancetype)objectWithItemProviderData:(NSData *)data
                                         typeIdentifier:(NSString *)typeIdentifier
                                                  error:(NSError **)outError;
    方法返回的是 dragItem.itemProvider.loadObject(NSData *) 中的NSData

    Code: [dragItem.itemProvider canLoadObjectOfClass:你的类型]]
          [dragItem.itemProvider loadObjectOfClass:你的类型 completionHandler:]



Advanced Topics

- Data Marshaling: 数据编组

    文件的拖拽有两种选项：
        直接提供副本
        提供url（意味着多个app可以共享一个文件, 对方修改，本地可以看到修改的地方(File Provider))

    提供数据有三种方式:
        直接提供NSData：itemProvider.registerDataRepresentation(...)
        提供一个文件或者文件夹：itemProvider.registerFileRepresentation(...fileOptions:[])
        作为 File Provider 的引用：itemProvider.registerFileRepresentation(...fileOptions:[.openInPlace])
    
    接收数据也有三种方式：
        直接拷贝出NSData 的副本：itemProvider.loadDataRepresentation(...)
        将文件或文件夹拷贝到自己的容器内：itemProvider.loadDataRepresentation(...)
        尝试在本地打开文件：itemProvider.loadInPlaceFileRepresentation(...)

    数据编组直接做好了数据的转换:
        提供者想要提供一个 NSData 类型数据，数据编组就直接将这个数据写入文件并提供url的副本
        如果提供者提供的是文件夹，然后数据编组就会把文件压缩并提供NSData

- 自定义Progress and cancellation, 见PDF

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler:
                    @escaping (Data?, Error?) -> Void) -> Progress? { let dataLoader = DataLoader()
        let progress = Progress(totalUnitCount: 100) 
        var shouldContinue = true
        progress.cancellationHandler = {
            shouldContinue = false 
        }
        dataLoader.beginLoading(update: { percentDone in 
            progress.completedUnitCount = percentDone 
            return shouldContinue
        }, completionHandler: completionHandler)
        return progress 
    }

- <NSItemProviderWriting>
      NSItemProviderRepresentationVisibility: 自定义类型对哪些可见: 对所有人可见; 同一个 team 可见; 仅对自己可见;

- NSItemProvider teamData
     @property  NSData *teamData // 只对组内其它app可见 8000字节, 作用? 
 
- NSItemProvider suggestedName
     @property  NSString *suggestedName;  // 文件名

- NSItemProvider
     @property  CGSize preferredPresentationSize

- File Provider 应用扩展
    这一应用扩展能够允许数据通过网络下载而传送, 即使你的主应用已被终止; 多个程序可以访问同一文件(无demo)
    File Provider Enhancements: WWDC 2017 session 243