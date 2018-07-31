//
//  Aubios.swift
//  aubioDemo
//
//  Created by lls on 2018/7/31.
//  Copyright © 2018年 demo. All rights reserved.
//

import Foundation
import AVFoundation

import aubio

class FVec {
    fileprivate let ptr: UnsafeMutablePointer<fvec_t>
    init(length: uint_t) {
        self.ptr = new_fvec(length)
    }
    subscript(position: uint_t) -> smpl_t {
        return fvec_get_sample(ptr, position)
    }
    deinit {
        del_fvec(ptr)
    }
}

class AubioTempo {
    private typealias Ptr = OpaquePointer
    private let ptr: Ptr
    
    private init(ptr: Ptr) {
        self.ptr = ptr
    }
    
    var bpm: smpl_t {
        return aubio_tempo_get_bpm(ptr)
    }
    
    func digest(data: FVec) -> FVec {
        let out = FVec(length: 1)
        aubio_tempo_do(ptr, data.ptr, out.ptr)
        return out
    }
    
    static func create(buf_size: uint_t, hop_size: uint_t, samplerate: uint_t) -> AubioTempo? {
        return "default".withCString { new_aubio_tempo($0, buf_size, hop_size, samplerate) }.map(AubioTempo.init)
    }
    
    deinit {
        del_aubio_tempo(ptr)
    }
}

class AubioSource {
    private typealias Ptr = OpaquePointer
    private let ptr: Ptr
    private init(ptr: Ptr) {
        self.ptr = ptr
    }
    
    static func create(path: String, hop_size: uint_t, samplerate: uint_t) -> AubioSource? {
        return path.withCString { new_aubio_source($0, samplerate, hop_size) }.map(AubioSource.init)
    }
    
    func `do`(_ fvec: FVec) -> uint_t {
        var read: uint_t = 1
        aubio_source_do(ptr, fvec.ptr, &read)
        return read
    }
    
    deinit {
        del_aubio_source(ptr)
    }
}

struct AubioSourceIterator: IteratorProtocol {
    static let frameLength: uint_t = 512
    private let out = FVec(length: frameLength)
    private let source: AubioSource
    typealias Element = FVec
    init(source: AubioSource) {
        self.source = source
    }
    mutating func next() -> AubioSourceIterator.Element? {
        if (source.do(out) >= AubioSourceIterator.frameLength) {
            return out
        } else {
            return nil
        }
    }
}

extension AubioSource: Sequence {
    typealias Iterator = AubioSourceIterator
    func makeIterator() -> AubioSource.Iterator {
        return .init(source: self)
    }
}

func testAudio(path: String, hopSize: uint_t, sampleRate: uint_t) {
    guard
        let tempo: AubioTempo = .create(buf_size: hopSize * 2, hop_size: hopSize, samplerate: sampleRate),
        let source: AubioSource = .create(path: path, hop_size: hopSize, samplerate: sampleRate)
        else { return }
    let tempos = Array(source.lazy.map(tempo.digest(data:)).map { $0[0] })
    let t = tempos.map { $0 == 0 ? "_" : "|" }.joined(separator: " ")
    print(path)
    print(t)
    print(tempos.count)
}
