# PKHImageCache

Simple asynchronous network retrieval and local caching for images on iOS.

### About

PKHImageCache is a minimalist module to load images into your UI from specified URLs asynchronously and cache them locally. It uses the NSCache class to cache images in memory, and also saves images to disk to persist between launches (also saving the images to your app's Caches directory).

A prime use-case for this module would be loading images into UITableView or UICollectionView cells (as shown in the example project).

PKHImageCache performs essentially the core functionality of the popular [SDWebImage][SDWebImage] library, but without all the bells and whistles. It was created to be a viable library for use in production, but also as a learning experiment for myself. The project is still in development and new features and refinements are in the pipeline. 

### Installation

The best way to add PKHImageCache to your project is to simply grab all the files in the `PKHImageCache` directory in the top-level of this repo. The files you need are:

* `UIImageView+PKHImageCache.h`
* `UIImageView+PKHImageCache.m`
* `PKHImageCache.h`
* `PKHImageCache.m`
* `PKHImageDownloadOperation.h`
* `PKHImageDownloadOperation.m`

### Usage

Import the `UIImageView+PKHImageCache.h` file into your view controller and call the 
```objective-c
- (void)pkhic_setImageWithURL:(NSURL *)imageURL andPlaceholderImage:(UIImage *)placeholder;
```
method when configuring your table/collection view cells. Provide a URL to the image needed and a placeholder image (either can be nil if needed).

PKHImageCache will take care of searching it's local caches for the image, and if present, load into the image view. If it's not present, it will retrieve the image from the network, save it to the local cache, and load it into the image view.


## License

The MIT License (MIT)

Copyright (c) 2015 Patrick Hanlon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[SDWebImage]:https://github.com/rs/SDWebImage
