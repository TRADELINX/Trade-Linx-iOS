//
//  WebResource.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/1/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import UIKit
import Moya

class WebResource {
    
    private lazy var provider = MoyaProvider<MartinsService>(plugins: [
        NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration.init(logOptions: [.verbose, .formatRequestAscURL]))
    ])
    private var _currentUser: User?
    
    var currentUser: User? {
        if _currentUser == .none {
            return User.restoreFromKeychain()
        }
        return _currentUser
    }
    
    // MARK: - Login -
    func login(email: String, password: String, completion: @escaping (Result<User, ResponseError>)->Void) {
        let login = Login(email: email, password: password)
        let request = AppRequest<Login>(data: login)
        provider.request(.login(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let userResponse = try response.map(AppResponse<User>.self)
                    if let value = userResponse.data {
                        self?._currentUser = value
                        value.persistToKeychain()
                    }
                    let userResult = userResponse.result()
                    completion(userResult)
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    func loginWithGoogle(register: SocialRegister, completion: @escaping (Result<User, ResponseError>)->Void) {
        let request = AppRequest<SocialRegister>(data: register)
        provider.request(.socialSignUp(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let userResponse = try response.map(AppResponse<User>.self)
                    if let value = userResponse.data {
                        self?._currentUser = value
                        value.persistToKeychain()
                    }
                    let userResult = userResponse.result()
                    completion(userResult)
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func register(_ register: Register, completion: @escaping (Result<AppResponse<User>, ResponseError>)->Void) {
        let request = AppRequest<Register>(data: register)
        provider.request(.signUp(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let userResponse = try response.map(AppResponse<User>.self)
                    completion(.success(userResponse))
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    func forgotPassword(passwordRequest: ForgotPassword, completion: @escaping (Result<AppResponse<Int>, ResponseError>)->Void) {
        let request = AppRequest(data: passwordRequest)
        provider.request(.forgotPassword(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Int>.self)
                    completion(.success(output))
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
                break
            case .failure(let error):
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    func logout() {
        guard let userId = self.currentUser?.userId else {
            return
        }
        provider.request(.logout(AppRequest(data: UserId(user_id: userId)))) { [weak self] (result) in
            switch result {
            case .success(let response):
                User.removeFromKeychain()
                self?._currentUser = nil
                AppLog.print(response)
                
            case .failure(let error):
                User.removeFromKeychain()
                self?._currentUser = nil
                AppLog.print(error)
            }
        }
    }
    
    // MARK: - Profile -
    func updateProfile(register: Register, completion: @escaping (Result<User, ResponseError>)->Void) {
        let request = AppRequest<Register>(data: register)
        provider.request(.updateProfile(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let userResponse = try response.map(AppResponse<User>.self)
                    if let user = userResponse.data {
                        self?._currentUser = user
                        user.persistToKeychain()
                    }
                    let userResult = userResponse.result()
                    completion(userResult)
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    func makeAvailableForBooking(register: Register, completion: @escaping (Result<Bool, ResponseError>)->Void) {
        updateProfile(register: register) { (result) in
            switch result {
            case .success(let user):
                completion(.success(user.isAvailableForBooking))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getProfile(completion: @escaping (Result<User, ResponseError>)->Void) {
        guard let userId = self.currentUser?.userId else { return }
        let request = AppRequest(data: UserId(user_id: userId))
        provider.request(.getProfile(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let userResponse = try response.map(AppResponse<User>.self)
                    if let user = userResponse.data {
                        self?._currentUser = user
                        user.persistToKeychain()
                    }
                    let userResult = userResponse.result()
                    completion(userResult)
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    // MARK: - TradeList -
    func serviceAndTradeList(completion: @escaping (Result<ServiceTradeList, ResponseError>)->Void) {
        provider.request(.serviceAndTradeList) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<ServiceTradeList>.self)
                    print(output)
                    completion(output.result())
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                print(error)
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    // MARK: - Image Uploading -
    func upload(images: [String: UIImage], progress: @escaping (Double)->Void, completion: @escaping (Result<AppResponse<[String: String]>, ResponseError>)->Void) {
        provider.request(.uploadImages(images), callbackQueue: nil, progress: { (progressResponse) in
            progress(progressResponse.progress)
            print(progressResponse.progress)
        }) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<[String: String]>.self)
                    completion(.success(output))
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.errorDescription)))
            }
        }
    }
    
    func deleteImage(request: DeleteImageRequest, completion: @escaping (Result<Void, ResponseError>)->Void) {
        let apiRequest = AppRequest<DeleteImageRequest>(data: request)
        provider.request(.deleteImage(apiRequest)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Int>.self)
                    if output.status == 1 {
                        completion(.success(()))
                    } else if let message = output.message {
                        completion(.failure(.message(message)))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: apiRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Time Slots -
    func addTimeSlot(request: TimeSlotRequest, completion: @escaping (Result<AppResponse<Int>, ResponseError>)->Void) {
        let timeRequest = AppRequest(data: request)
        provider.request(.addTimeSlot(timeRequest)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Int>.self)
                    completion(.success(output))
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self.extraLogInfo(request: timeRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func updateTimeSlot(request: TimeSlotRequest, completion: @escaping (Result<AppResponse<Int>, ResponseError>)->Void) {
        let timeRequest = AppRequest(data: request)
        provider.request(.editTimeSlot(timeRequest)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Int>.self)
                    completion(.success(output))
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: timeRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func dateSlots(completion: @escaping (Result<[DateSlotResponse], ResponseError>)->Void) -> Cancellable? {
        guard let userId = self.currentUser?.userId else {
            return nil
        }
        let dateRequest = AppRequest(data: UserId(user_id: userId))
        return provider.request(.getDateSlot(dateRequest)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<[DateSlotResponse]>.self)
                    completion(output.result())
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: dateRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func timeSlots(for request: DateTimeSlotRequest, completion: @escaping (Result<PlanResponse, ResponseError>)->Void) -> Cancellable {
        let slotRequest = AppRequest(data: request)
        return provider.request(.getTimeSlot(slotRequest)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<PlanResponse>.self)
                    completion(output.result())
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: slotRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func deleteTimeSlot(for request: DeleteTimeSlotRequest, completion: @escaping (Result<Bool, ResponseError>)->Void) {
        let deleteRequest = AppRequest(data: request)
        provider.request(.deleteTimeSlot(deleteRequest)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<TimeSlotResponse>.self)
                    if output.status == 1 {
                        completion(.success(true))
                    } else {
                        completion(.failure(.message("Something went wrong!")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: deleteRequest))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Messages -
    func messages(for userId: Int, completion: @escaping (Result<[MessageItem], ResponseError>)->Void) {
        let request = AppRequest<UserId>(data: UserId(user_id: userId))
        provider.request(.messages(request)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<[MessageItem]>.self)
                    if let messages = output.data, messages.count == 0 {
                        completion(.failure(.emptyData(nil, "No messages yet.", "")))
                        return
                    }
                    completion(output.result())
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error, extraInfo: self?.extraLogInfo(request: request))
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func addLastMessage(for request: LastMessageRequest) {
        provider.request(.addLastMessage(AppRequest<LastMessageRequest>(data: request))) { (result) in
            AppLog.print(result)
        }
    }
    
    // MARK: - Ratings -
    func ratings(completion: @escaping (Result<[Rating], ResponseError>)->Void) {
        guard let userId = self.currentUser?.userId else { return }
        let request = AppRequest(data: UserId(user_id: userId))
        provider.request(.ratings(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<[Rating]>.self)
                    if let ratings = output.data, ratings.count > 0 {
                        completion(.success(ratings))
                    } else {
                        completion(.failure(.emptyData(nil, "No Ratings", "")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Jobs -
    func startJob(statusUpdate: JobStatusUpdate, completion: @escaping (Result<Bool, ResponseError>)->Void) {
        let request = AppRequest(data: statusUpdate)
        provider.request(.startJob(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Bool>.self)
                    if output.status == 1 {
                        completion(.success(true))
                    } else if let message = output.message {
                        completion(.failure(.message(message)))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func updateJob(status: UpdateJobRequest, completion: @escaping (Result<String, ResponseError>)->Void) {
        let request = AppRequest(data: status)
        provider.request(.updateJob(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let output = try response.map(AppResponse<Bool>.self)
                    if let message = output.message {
                        completion(.success(message))
                    } else {
                        completion(.failure(.message("Something went wrong.")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Notifications -
    func notifications(userId: Int, completion: @escaping (Result<[NotificationItem], ResponseError>)->Void) {
        let request = AppRequest(data: UserId(user_id: userId))
        provider.request(.notifications(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(AppResponse<[NotificationItem]>.self)
                    if let notifications = decoded.data, notifications.count > 0 {
                        completion(.success(notifications))
                    } else {
                        completion(.failure(.emptyData(nil, "No Notifications yet.", "")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    func deleteAllNotifications(userId: Int, completion: @escaping (Result<Int, ResponseError>)->Void) {
        let request = AppRequest(data: UserId(user_id: userId))
        provider.request(.clearNotification(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(AppResponse<Int>.self)
                    if let status = decoded.data {
                        completion(.success(status))
                    } else if let message = decoded.message {
                        completion(.failure(.message(message)))
                    } else {
                        completion(.failure(.message("Something went wrong.")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
    
    // MARK: - Booking -
    func acceptOrRejectBookingProposal(request: ProposalAction, completion: @escaping (Result<String, ResponseError>)->Void) {
        let actionRequest = AppRequest(data: request)
        provider.request(.acceptOrRejectProposal(actionRequest)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(AppResponse<Bool>.self)
                    if let message = decoded.message {
                        completion(.success(message))
                    } else {
                        completion(.failure(.message("Something went wrong.")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func bookingStatus(jobId: UserJobId, completion: @escaping (Result<BookingStatusResponse, ResponseError>)->Void) {
        let request = AppRequest(data: jobId)
        provider.request(.bookingStatus(request)) { (result) in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(AppResponse<BookingStatusResponse>.self)
                    if let bookingResponse = decoded.data {
                        completion(.success(bookingResponse))
                    } else if let message = decoded.message {
                        completion(.failure(.message(message)))
                    } else {
                        completion(.failure(.message("Something went wrong")))
                    }
                } catch {
                    if AppConfig.shouldDisplayDebugMessage {
                        completion(.failure(.debugMessage(error)))
                        AppLog.print(error)
                    } else {
                        completion(.failure(.canNotParse))
                    }
                }
            case .failure(let error):
                completion(.failure(.message(error.localizedDescription)))
            }
        }
    }
}

// MARK: - Logging Information -
extension WebResource {
    func extraLogInfo<A: Encodable>(request: AppRequest<A>) -> Any? {
        if let currentUser = currentUser {
            return [
                "userId": currentUser.id,
                "email": currentUser.email ?? "No Email",
                "request": request
            ]
        }
        return request
    }
}
