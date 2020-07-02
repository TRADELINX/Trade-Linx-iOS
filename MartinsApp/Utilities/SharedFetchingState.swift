//
//  SharedFetchingState.swift
//
//  Created by Neil Jain on 4/7/19.
//  Copyright © 2019 Neil Jain. All rights reserved.
//

import Foundation

class SharedFetchingState<A> {
    private var observations: [UUID: (FetchingState<A>)->Void] = [:]
    
    var state: FetchingState<A> {
        didSet {
            self.observations.forEach({$0.value(state)})
        }
    }
    
    init(state: FetchingState<A>) {
        self.state = state
    }
    
    func onStateChange(_ observation: @escaping (FetchingState<A>)->Void) -> UUID {
        let uuid = UUID()
        self.observations[uuid] = observation
        observation(self.state)
        return uuid
    }
    
    func removeObservation(token: UUID?) {
        guard let validUUID = token else { return }
        self.observations.removeValue(forKey: validUUID)
    }
}
