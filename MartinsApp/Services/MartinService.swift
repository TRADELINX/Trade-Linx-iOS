//
//  MartinService.swift
//  MartinsApp
//
//  Created by Neil Jain on 6/8/19.
//  Copyright © 2019 Ratnesh Jain. All rights reserved.
//

import Foundation
import Moya

struct AppRequest<A: Encodable>: Encodable {
    var data: A
}

enum ResponseError: Error {
    case canNotParse
    case emptyData(UIImage?, String, String)
    case message(String?)
    case debugMessage(Any)
}

extension ResponseError {
    var title: String {
        switch self {
        case .canNotParse:
            return "Oops"
        case .emptyData(_, let title, _):
            return title
        case .message:
            return "Error"
        case .debugMessage:
            return "Error"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .emptyData(let image, _, _):
            return image
        default:
            return nil
        }
    }
}

struct AppResponse<A: Decodable>: Decodable {
    var status: Int
    var message: String?
    var data: A?
}

enum MartinsService {
    case login(AppRequest<Login>)
    case signUp(AppRequest<Register>)
    case socialSignUp(AppRequest<SocialRegister>)
    case logout(AppRequest<UserId>)
    case forgotPassword(AppRequest<ForgotPassword>)
    case changePassword(AppRequest<ChangePassword>)
    case getProfile(AppRequest<UserId>)
    case updateProfile(AppRequest<Register>)
    case uploadImages([String: UIImage])
    case uploadImage(UIImage)
    case serviceAndTradeList
    case deleteImage(AppRequest<DeleteImageRequest>)
    case addTimeSlot(AppRequest<TimeSlotRequest>)
    case editTimeSlot(AppRequest<TimeSlotRequest>)
    case getDateSlot(AppRequest<UserId>)
    case getTimeSlot(AppRequest<DateTimeSlotRequest>)
    case deleteTimeSlot(AppRequest<DeleteTimeSlotRequest>)
    case messages(AppRequest<UserId>)
    case addLastMessage(AppRequest<LastMessageRequest>)
    case ratings(AppRequest<UserId>)
    case startJob(AppRequest<JobStatusUpdate>)
    case updateJob(AppRequest<UpdateJobRequest>)
    case notifications(AppRequest<UserId>)
    case acceptOrRejectProposal(AppRequest<ProposalAction>)
    case clearNotification(AppRequest<UserId>)
    case bookingStatus(AppRequest<UserJobId>)
}

extension MartinsService: TargetType {
    var baseURL: URL {
        return AppConfig.host.baseURL
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .signUp:
            return "/register"
        case .socialSignUp:
            return "/socialRegister"
        case .logout:
            return "/logout"
        case .forgotPassword:
            return "/forgotPassword"
        case .changePassword:
            return "/changePassword"
        case .getProfile:
            return "/getProfile"
        case .updateProfile:
            return "/updateProfile"
        case .uploadImages:
            return "/imageupload"
        case .uploadImage:
            return "/imageupload"
        case .serviceAndTradeList:
            return "/servicetradelist"
        case .deleteImage:
            return "/deleteimage"
        case .addTimeSlot:
            return "/addTimeSlot"
        case .editTimeSlot:
            return "/editTimeSlot"
        case .getDateSlot:
            return "/getDateSlot"
        case .getTimeSlot:
            return "/getTimeSlot"
        case .deleteTimeSlot:
            return "/deleteTimeSlot"
        case .messages:
            return "/chatList"
        case .addLastMessage:
            return "/addLastmessage"
        case .ratings:
            return "/myJobsAndRating"
        case .startJob:
            return "/jobStart"
        case .updateJob:
            return "/updateJobStatus"
        case .notifications:
            return "/notification"
        case .acceptOrRejectProposal:
            return "/booking-accept-reject"
        case .clearNotification:
            return "/clearnotification"
        case .bookingStatus:
            return "/bookingStatus"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .serviceAndTradeList:
            return .get
        default:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .login(let request):
            return .requestJSONEncodable(request)
        case .signUp(let request):
            return .requestJSONEncodable(request)
        case .socialSignUp(let request):
            return .requestJSONEncodable(request)
        case .getProfile(let request):
            return .requestJSONEncodable(request)
        case .updateProfile(let request):
            return .requestJSONEncodable(request)
        case .forgotPassword(let request):
            return .requestJSONEncodable(request)
        case .changePassword(let request):
            return .requestJSONEncodable(request)
        case .logout(let request):
            return .requestJSONEncodable(request)
        case .uploadImages(let images):
            var imagesData = [MultipartFormData]()
            for (name, image) in images {
                let imageData = image.jpegData(compressionQuality: 0.3)!
                let data = MultipartFormData(provider: .data(imageData), name: name, fileName: "\(name).jpg", mimeType: "image/jpeg")
                imagesData.append(data)
            }
            return .uploadMultipart(imagesData)
        case .uploadImage(let image):
            let imageData = image.jpegData(compressionQuality: 0.3)!
            let imageFormData = MultipartFormData(provider: .data(imageData), name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            return .uploadMultipart([imageFormData])
        case .serviceAndTradeList:
            return .requestPlain
        case .deleteImage(let request):
            return .requestJSONEncodable(request)
        case .addTimeSlot(let request):
            return .requestJSONEncodable(request)
        case .editTimeSlot(let request):
            return .requestJSONEncodable(request)
        case .getDateSlot(let request):
            return .requestJSONEncodable(request)
        case .getTimeSlot(let request):
            return .requestJSONEncodable(request)
        case .deleteTimeSlot(let request):
            return .requestJSONEncodable(request)
        case .messages(let request):
            return .requestJSONEncodable(request)
        case .addLastMessage(let request):
            return .requestJSONEncodable(request)
        case .ratings(let request):
            return .requestJSONEncodable(request)
        case .startJob(let request):
            return .requestJSONEncodable(request)
        case .updateJob(let request):
            return .requestJSONEncodable(request)
        case .notifications(let request):
            return .requestJSONEncodable(request)
        case .acceptOrRejectProposal(let request):
            return .requestJSONEncodable(request)
        case .clearNotification(let request):
            return .requestJSONEncodable(request)
        case .bookingStatus(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

extension AppResponse {
    func result() -> Result<A, ResponseError> {
        if self.status == 1, let value = self.data {
            return .success(value)
        } else {
            return .failure(.message(message))
        }
    }
}

extension ResponseError {
    var message: String {
        switch self {
        case .canNotParse:
            return "Temporary server down. Please try again."
            //return "There is something went wrong."
        case .emptyData(_, _, let message):
            return message
        case .message(let string):
            return string ?? "There is something went wrong here."
        case .debugMessage(let any):
            return String(describing: any)
        }
    }
}

struct DeleteImageRequest: Codable {
    var image_id: Int
    var tablename: TableName
}

enum TableName: String, Codable {
    case userQualifications = "UserQualification"
    case userWorkImage = "UserWorkimage"
}

enum BookingStatus: String, Codable {
    case start = "1"
    case complete = "2"
    case rejectedByUser = "3"
    case rating = "4"
    case pending = "5"
}

struct BookingStatusResponse: Codable {
    var user_job_id: Int?
    var user_id: Int?
    var company_id: Int?
    var price: String?
    var booking_start_date: String?
    var booking_end_date: String?
    var status: BookingStatus?
}
