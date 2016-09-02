//
//  WebService.swift
//  rndSoap
//
//  Created by Marielle Miranda on 8/5/16.
//  Copyright © 2016 Bluesky Outsourcing Ltd. All rights reserved.
//

import UIKit

let urlLSS = "http://180.87.143.45/ph.funloyalty.api/LoyaltySystemServiceSoapBinding.asmx?WSDL"
let urlLS3PPS = "http://180.87.143.45/ph.funloyalty.api/LoyaltySystem3PPServiceSoapBinding.asmx?WSDL"
let timeOut = 60.0

enum WebServiceFor: String {
    case CheckFbInfo = "checkFbInfo", CheckMsisdn = "checkMsisdn", Earn = "earn", EarnMsisdn = "earnMsisdn", EarnReversal = "earnReversal", Inquire = "inquire",  InquireMsisdn = "inquireMsisdn", MarkAsSold = "markAsSold", PasaPoints = "pasaPoints", PasaPointsMsisdn = "pasaPointsMsisdn", Redeem = "redeem", RedeemMsisdn = "redeemMsisdn", RedeemReversal = "redeemReversal", RedeemStamp = "redeemStamp", Register = "register", RegisterFbInfo = "registerFbInfo", ResendPin = "resendPin", UpdateFbInfo = "updateFbInfo", ValidateCardPin = "validateCardPin", RegisterVirtualCard = "TLCILSAPI3PP_REGVIRTUALCARD", ValidateVirtualCard = "TLCILSAPI3PP_VLDTVIRTUALCARD", GetDashboardInfo = "TLCILSAPI3PP_MOBILENUMBER"
}

protocol WebServiceDelegate {
    func webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary: NSDictionary) -> Void
    func webServiceDidFailWithError(error: NSError) -> Void
    func webServiceDidTimeout() -> Void
}

class WebService: NSObject, NSURLConnectionDelegate, XMLParserDelegate {
    
    //MARK: - Properties
    
    //MARK: Public
    
    var name = ""
    var delegate: WebServiceDelegate?
    
    //MARK: Private
    
    //MARK: SOAP Request
    
    private var strSoapActionLSS = "http://www.tlc.com.ph/loyalty/wsdl/execute/"
    private var strSoapActionLS3PPS = "http://www.tlci.com.ph/"
    
    private var strHeading = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:exec=\"http://www.tlc.com.ph/loyalty/wsdl/execute/\"><soapenv:Header/><soapenv:Body>"
    
    private var strClosing = "</soapenv:Body></soapenv:Envelope>"
    
    private var dictParams = NSMutableDictionary()
    
    private var timer: NSTimer? =  NSTimer()
    
    private var request: WebServiceFor?
    
    //MARK: NSURLConnection
    
    private let trustedHosts = ["180.87.143.45"]
    
    private var _mutableData: NSMutableData?
    private var mutableData: NSMutableData {
        get {
            if self._mutableData == nil {
                self._mutableData = NSMutableData()
            }
            
            return self._mutableData!
        }
    }
    
    private var _xmlParser: XMLParser?
    private var xmlParser: XMLParser {
        get {
            if self._xmlParser == nil {
                self._xmlParser = XMLParser()
                self._xmlParser?.delegate = self
            }
            
            return self._xmlParser!
        }
    }
    
    //MARK: - Methods
    
    //MARK: Private
    
    //MARK: URL Connection
    
    private func postWithDictionary(dictValues: NSDictionary) {
        let message = dictValues["soapMessage"] as! String
        let action = dictValues["soapAction"] as! String
        let url = dictValues["url"] as! String
        
        let request = NSMutableURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: timeOut)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(message.characters.count)", forHTTPHeaderField: "Content-Length")
        request.HTTPMethod = "POST"
        request.HTTPBody = message.dataUsingEncoding(NSUTF8StringEncoding)
        
        let connection = NSURLConnection(request: request, delegate: self)
        connection!.start()
        
        self.stopLossTimer()
        self.startLossTimer()
    }
    
    private func startLossTimer() {
        //uncomment
        //self.timer = NSTimer.scheduledTimerWithTimeInterval(timeOut, target: self, selector:  #selector(WebService.didReachSendingTimeout), userInfo: nil, repeats: false)
    }
    
    private func stopLossTimer() {
        if (self.timer != nil) {
            self.timer!.invalidate()
        }
        
        self.timer = nil
    }
    
    @objc private func didReachSendingTimeout() {
        self.stopLossTimer()
        self._mutableData = nil

        self.delegate?.webServiceDidTimeout()
    }
    
    //MARK: SOAP Messages
    
    private func getSoapMessageWithWebServiceFor(webServiceFor: WebServiceFor) -> String {
        self.request = webServiceFor
        var soapMessage = self.strHeading
        
        switch webServiceFor {
            
        case .CheckFbInfo:
            soapMessage = soapMessage.stringByAppendingString(self.messageForCheckFBInfo())
            break
            
        case .CheckMsisdn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForCheckMsisdn())
            break
            
        case .Earn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForEarn())
            break
            
        case .EarnMsisdn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForEarnMsisdn())
            break
            
        case .EarnReversal:
            soapMessage = soapMessage.stringByAppendingString(self.messageForEarnReversal())
            break
            
        case .Inquire:
            soapMessage = soapMessage.stringByAppendingString(self.messageForInquire())
            break
            
        case .InquireMsisdn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForInquireMsisdn())
            break
            
        case .MarkAsSold:
            soapMessage = soapMessage.stringByAppendingString(self.messageForMarkAsSold())
            break
            
        case .PasaPoints:
            soapMessage = soapMessage.stringByAppendingString(self.messageForPasaPoints())
            break
            
        case .PasaPointsMsisdn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForPasaPointsMsisdn())
            break
            
        case .Redeem:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRedeem())
            break
            
        case .RedeemMsisdn:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRedeemMsisdn())
            break
            
        case .RedeemReversal:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRedeemReversal())
            break
            
        case .RedeemStamp:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRedeemStamp())
            break
            
        case .Register:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRegister())
            break
            
        case .RegisterFbInfo:
            soapMessage = soapMessage.stringByAppendingString(self.messageForRegisterFbInfo())
            break
            
        case .ResendPin:
            soapMessage = soapMessage.stringByAppendingString(self.messageForResendPin())
            break
            
        case .UpdateFbInfo:
            soapMessage = soapMessage.stringByAppendingString(self.messageForUpdateFbInfo())
            break
            
        case .ValidateCardPin:
            soapMessage = soapMessage.stringByAppendingString(self.messageForValidateCardPin())
            break
            
        case .RegisterVirtualCard:
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(":exec", withString: ":tlci")
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(strSoapActionLSS, withString: strSoapActionLS3PPS)
            soapMessage = soapMessage.stringByAppendingString(self.messageForRegVirtualCard())
            break
            
        case .ValidateVirtualCard:
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(":exec", withString: ":tlci")
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(strSoapActionLSS, withString: strSoapActionLS3PPS)
            soapMessage = soapMessage.stringByAppendingString(self.messageForVldtVirtualCard())
            break
            
        case .GetDashboardInfo:
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(":exec", withString: ":tlci")
            soapMessage = soapMessage.stringByReplacingOccurrencesOfString(strSoapActionLSS, withString: strSoapActionLS3PPS)
            soapMessage = soapMessage.stringByAppendingString(self.messageForGetDashboardInfo())
            break
        }
        
        soapMessage = soapMessage.stringByAppendingString(self.strClosing)
        return soapMessage
    }
    
    private func messageForCheckFBInfo() -> String {
        let message = String(format: "<exec:checkFbInfo><exec:CheckFbInfoRequest><FacebookId>%@</FacebookId></exec:CheckFbInfoRequest></exec:checkFbInfo>", self.dictParams["facebookId"] as! String)
        
        return message
    }
    
    private func messageForCheckMsisdn() -> String {
        let message = String(format: "<exec:checkMsisdn><exec:CheckMsisdnRequest><Msisdn>%@</Msisdn></exec:CheckMsisdnRequest></exec:checkMsisdn>", self.dictParams["msisdn"] as! String)
        
        return message
    }
    
    private func messageForEarn() -> String {
        let message = String(format: "<exec:earn><exec:EarnRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><Amount>%@</Amount><Currency>%@</Currency><Branch>%@</Branch><PaymentChannel>%@</PaymentChannel><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:EarnRequest></exec:earn>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["branch"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForEarnMsisdn() -> String {
        let message = String(format: "<exec:earnMsisdn><exec:EarnMsisdnRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><MobileNumber>%@</MobileNumber><Amount>%@</Amount><Currency>%@</Currency><Branch>%@</Branch><PaymentChannel>%@</PaymentChannel><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:EarnMsisdnRequest></exec:earnMsisdn>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["mobileNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["branch"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForEarnReversal() -> String {
        let message = String(format: "<exec:earnReversal><exec:EarnReversalRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:EarnReversalRequest>/exec:earnReversal>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForInquire() -> String {
        let message = String(format: "<exec:inquire><exec:InquireRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:InquireRequest></exec:inquire>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForInquireMsisdn() -> String {
        let message = String(format: "<exec:inquireMsisdn><exec:InquireMsisdnRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><MobileNumber>%@</MobileNumber><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:InquireMsisdnRequest></exec:inquireMsisdn>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["mobileNumber"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForMarkAsSold() -> String {
        let message = String(format: "<exec:markAsSold><exec:MarkAsReadRequest><TransactionId>%@</TransactionId><CardNumber>%@</CardNumber><MerchantAlias>%@</MerchantAlias><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:MarkAsReadRequest></exec:markAsSold>", self.dictParams["transactionId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["merchantAlias"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForPasaPoints() -> String {
        let message = String(format: "<exec:pasaPoints><exec:PasaPointsRequest><TransactionId>%@</TransactionId><SenderCardNumber>%@</SenderCardNumber><ReceiverCardNumber>%@</ReceiverCardNumber><Amount>%@</Amount><Currency>%@</Currency><PaymentChannel>%@</PaymentChannel><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:PasaPointsRequest></exec:pasaPoints>", self.dictParams["transactionId"] as! String, self.dictParams["senderCardNumber"] as! String, self.dictParams["receiverCardNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForPasaPointsMsisdn() -> String {
        let message = String(format: "<exec:pasaPointsMsisdn><exec:PasaPointsMsisdnRequest><TransactionId>%@</TransactionId><SenderMsisdn>%@</SenderMsisdn><SenderPin>%@</SenderPin><ReceiverMsisdn>%@</ReceiverMsisdn><Amount>%@</Amount><Currency>%@</Currency><PaymentChannel>%@</PaymentChannel><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:PasaPointsMsisdnRequest></exec:pasaPointsMsisdn>", self.dictParams["transactionId"] as! String, self.dictParams["senderMsisdn"] as! String, dictParams["senderPin"] as! String, self.dictParams["receiverMsisdn"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRedeem() -> String {
        let message = String(format: "<exec:redeem><exec:RedeemRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><Amount>%@</Amount><Currency>%@</Currency><Branch>%@</Branch><PaymentChannel>%@</PaymentChannel><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:RedeemRequest></exec:redeem>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["branch"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRedeemMsisdn() -> String {
        let message = String(format: "<exec:redeemMsisdn><exec:RedeemMsisdnRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><MobileNumber>%@</MobileNumber><Amount>%@</Amount><PIN>%@</PIN><Currency>%@</Currency><Branch>%@</Branch><PaymentChannel>%@</PaymentChannel><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:RedeemMsisdnRequest></exec:redeemMsisdn>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["mobileNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["pin"] as! String, self.dictParams["currency"] as! String, self.dictParams["branch"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRedeemReversal() -> String {
        let message = String(format: "<exec:redeemReversal><exec:RedeemReversalRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:RedeemReversalRequest></exec:redeemReversal>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRedeemStamp() -> String {
        let message = String(format: "<exec:redeemStamp><exec:RedeemStampsRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><Amount>%@</Amount><Currency>%@</Currency><Branch>%@</Branch><PaymentChannel>%@</PaymentChannel><ModeOfPayment>%@</ModeOfPayment><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:RedeemStampsRequest></exec:redeemStamp>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["amount"] as! String, self.dictParams["currency"] as! String, self.dictParams["branch"] as! String, self.dictParams["paymentChannel"] as! String, self.dictParams["modeOfPayment"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRegister() -> String {
        let message = String(format: "<exec:register><exec:RegisterRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><Msisdn>%@</Msisdn><Channel>%@</Channel><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:RegisterRequest></exec:register>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String, self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["msisdn"] as! String, self.dictParams["channel"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRegisterFbInfo() -> String {
        let message = String(format: "<exec:registerFbInfo><exec:fbRequest><FacebookId>%@</FacebookId><FirstName>%@</FirstName><LastName>%@</LastName><MiddleName>%@</MiddleName><Birthday>%@</Birthday><Address>%@</Address><Email>%@</Email><Msisdn>%@</Msisdn></exec:fbRequest></exec:registerFbInfo>", self.dictParams["facebookId"] as! String, self.dictParams["firstName"] as! String, self.dictParams["lastName"] as! String, self.dictParams["middleName"] as! String, self.dictParams["birthday"] as! String, self.dictParams["address"] as! String, self.dictParams["email"] as! String, self.dictParams["msisdn"] as! String)
        
        return message
    }
    
    private func messageForResendPin() -> String {
        let message = String(format: "<exec:resendPin><exec:ResendPinRequest><TransactionId>%@</TransactionId><MobileNumber>%@</MobileNumber></exec:ResendPinRequest></exec:resendPin>", self.dictParams["transactionId"] as! String, self.dictParams["mobileNumber"] as! String)
        
        return message
    }
    
    private func messageForUpdateFbInfo() -> String {
        let message = String(format: "<exec:updateFbInfo><exec:fbUpdateRequest><TRANSACTIONID>%@</TRANSACTIONID><MSISDN>%@</MSISDN><FIRSTNAME>%@</FIRSTNAME><MIDDLENAME>%@</MIDDLENAME><LASTNAME>%@</LASTNAME><GENDER>%@</GENDER><BIRTHDATE>%@</BIRTHDATE><EMAIL>%@</EMAIL><ADDRESS>%@</ADDRESS></exec:fbUpdateRequest></exec:updateFbInfo>", self.dictParams["transactionId"] as! String, self.dictParams["msisdn"] as! String, self.dictParams["firstName"] as! String,  self.dictParams["middleName"] as! String, self.dictParams["lastName"] as! String, self.dictParams["gender"] as! String, self.dictParams["birthday"] as! String, self.dictParams["email"] as! String, self.dictParams["address"] as! String)
        
        return message
    }
    
    private func messageForValidateCardPin() -> String {
        let message = String(format: "<exec:validateCardPin><exec:ValidateCardPinRequest><TransactionId>%@</TransactionId><UserId>%@</UserId><Password>%@</Password><MerchantId>%@</MerchantId><CardNumber>%@</CardNumber><Msisdn>%@</Msisdn><CardPin>%@</CardPin><Channel>%@</Channel><RequestTimezone>%@</RequestTimezone><RequestTimestamp>%@</RequestTimestamp></exec:ValidateCardPinRequest></exec:validateCardPin>", self.dictParams["transactionId"] as! String, self.dictParams["userId"] as! String, self.dictParams["password"] as! String,  self.dictParams["merchantId"] as! String, self.dictParams["cardNumber"] as! String, self.dictParams["msisdn"] as! String, self.dictParams["cardPin"] as! String, self.dictParams["channel"] as! String, self.dictParams["requestTimezone"] as! String, self.dictParams["requestTimestamp"] as! String)
        
        return message
    }
    
    private func messageForRegVirtualCard() -> String {
        let message = String(format: "<tlci:TLCILSAPI3PP_REGVIRTUALCARD><tlci:TLCILSAPI3PPRVCRequest><TRANSACTIONID>%@</TRANSACTIONID><MOBILENUMBER>%@</MOBILENUMBER></tlci:TLCILSAPI3PPRVCRequest></tlci:TLCILSAPI3PP_REGVIRTUALCARD>", self.dictParams["transactionId"] as! String, self.dictParams["mobileNumber"] as! String)
        
        return message
    }
    
    private func messageForVldtVirtualCard() -> String {
        let message = String(format: "<tlci:TLCILSAPI3PP_VLDTVIRTUALCARD><tlci:TLCILSAPI3PPVVCRequest><TRANSACTIONID>%@</TRANSACTIONID><MOBILENUMBER>%@</MOBILENUMBER><PIN>%@</PIN><CUSTOMER><FACEBOOKID>%@</FACEBOOKID><LASTNAME>%@</LASTNAME><FIRSTNAME>%@</FIRSTNAME><SECONDNAME>%@</SECONDNAME><BIRTHDAY>%@</BIRTHDAY><GENDER>%@</GENDER><ADDRESS>%@</ADDRESS><EMAIL>%@</EMAIL></CUSTOMER></tlci:TLCILSAPI3PPVVCRequest></tlci:TLCILSAPI3PP_VLDTVIRTUALCARD>", self.dictParams["transactionId"] as! String, self.dictParams["mobileNumber"] as! String, self.dictParams["cardPin"] as! String,  self.dictParams["facebookId"] as! String, self.dictParams["lastName"] as! String, self.dictParams["firstName"] as! String, self.dictParams["secondName"] as! String, self.dictParams["birthday"] as! String, self.dictParams["gender"] as! String, self.dictParams["address"] as! String, self.dictParams["email"] as! String)
        
        return message
    }
    
    private func messageForGetDashboardInfo() -> String {
        let message = String(format: "<tlci:TLCILSAPI3PP_MOBILENUMBER><tlci:TLCILSAPI3PPMNRequest><TRANSACTIONID>%@</TRANSACTIONID><MOBILENUMBER>%@</MOBILENUMBER></tlci:TLCILSAPI3PPMNRequest></tlci:TLCILSAPI3PP_MOBILENUMBER>", self.dictParams["transactionId"] as! String, self.dictParams["mobileNumber"] as! String)
        
        return message
    }
    
    //MARK: Public
    
    func connectAndCheckFBInfoWithId(id: String) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["facebookId"] = id
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.CheckFbInfo.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.CheckFbInfo),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndCheckMsisdnWithMsisdn(msisdn: String) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["msisdn"] = msisdn
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.CheckMsisdn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.CheckMsisdn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndEarnWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["branch"] = dictInfo["branch"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.Earn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.Earn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndEarnMsisdnWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["branch"] = dictInfo["branch"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.EarnMsisdn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.EarnMsisdn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndEarnReversalWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.EarnReversal.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.EarnReversal),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndInquireWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.Inquire.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.Inquire),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndInquireMsisdnWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.InquireMsisdn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.InquireMsisdn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndMarkAsSoldWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["merchantAlias"] = dictInfo["merchantAlias"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.MarkAsSold.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.MarkAsSold),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndPasaPointsWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["senderCardNumber"] = dictInfo["senderCardNumber"] as! String
        self.dictParams["receiverCardNumber"] = dictInfo["receiverCardNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.PasaPoints.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.PasaPoints),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndPasaPointsMsisdnWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["senderMsisdn"] = dictInfo["senderMsisdn"] as! String
        self.dictParams["senderPin"] = dictInfo["senderPin"] as! String
        self.dictParams["receiverMsisdn"] = dictInfo["receiverMsisdn"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.PasaPointsMsisdn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.PasaPointsMsisdn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRedeemWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["branch"] = dictInfo["branch"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.Redeem.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.Redeem),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRedeemMsisdnWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["pin"] = dictInfo["pin"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["branch"] = dictInfo["branch"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.RedeemMsisdn.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.RedeemMsisdn),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRedeemReversalWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.RedeemReversal.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.RedeemReversal),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRedeemStampWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["amount"] = dictInfo["amount"] as! String
        self.dictParams["currency"] = dictInfo["currency"] as! String
        self.dictParams["branch"] = dictInfo["branch"] as! String
        self.dictParams["paymentChannel"] = dictInfo["paymentChannel"] as! String
        self.dictParams["modeOfPayment"] = dictInfo["modeOfPayment"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.RedeemStamp.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.RedeemStamp),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRegisterWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["msisdn"] = dictInfo["msisdn"] as! String
        self.dictParams["channel"] = dictInfo["channel"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.Register.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.Register),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRegisterFbInfoWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["facebookId"] = dictInfo["facebookId"] as! String
        self.dictParams["firstName"] = dictInfo["firstName"] as! String
        self.dictParams["lastName"] = dictInfo["lastName"] as! String
        self.dictParams["middleName"] = dictInfo["middleName"] as! String
        self.dictParams["birthday"] = dictInfo["birthday"] as! String
        self.dictParams["address"] = dictInfo["address"] as! String
        self.dictParams["email"] = dictInfo["email"] as! String
        self.dictParams["msisdn"] = dictInfo["msisdn"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.RegisterFbInfo.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.RegisterFbInfo),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndResendPinWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.ResendPin.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.ResendPin),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndUpdateFbInfoWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["msisdn"] = dictInfo["msisdn"] as! String
        self.dictParams["firstName"] = dictInfo["firstName"] as! String
        self.dictParams["middleName"] = dictInfo["middleName"] as! String
        self.dictParams["lastName"] = dictInfo["lastName"] as! String
        self.dictParams["gender"] = dictInfo["gender"] as! String
        self.dictParams["birthday"] = dictInfo["birthday"] as! String
        self.dictParams["email"] = dictInfo["email"] as! String
        self.dictParams["address"] = dictInfo["address"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.UpdateFbInfo.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.UpdateFbInfo),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndValidateCardPinWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["userId"] = dictInfo["userId"] as! String
        self.dictParams["password"] = dictInfo["password"] as! String
        self.dictParams["merchantId"] = dictInfo["merchantId"] as! String
        self.dictParams["cardNumber"] = dictInfo["cardNumber"] as! String
        self.dictParams["msisdn"] = dictInfo["msisdn"] as! String
        self.dictParams["cardPin"] = dictInfo["cardPin"] as! String
        self.dictParams["channel"] = dictInfo["channel"] as! String
        self.dictParams["requestTimezone"] = dictInfo["requestTimezone"] as! String
        self.dictParams["requestTimestamp"] = dictInfo["requestTimestamp"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLSS.stringByAppendingString(WebServiceFor.ValidateCardPin.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.ValidateCardPin),
            "url" : urlLSS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndRegisterVirtualCardWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLS3PPS.stringByAppendingString(WebServiceFor.RegisterVirtualCard.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.RegisterVirtualCard),
            "url" : urlLS3PPS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndValidateVirtualCardWithInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        self.dictParams["cardPin"] = dictInfo["cardPin"] as! String
        self.dictParams["facebookId"] = dictInfo["facebookId"] as! String
        self.dictParams["lastName"] = dictInfo["lastName"] as! String
        self.dictParams["firstName"] = dictInfo["firstName"] as! String
        self.dictParams["secondName"] = dictInfo["secondName"] as! String
        self.dictParams["birthday"] = dictInfo["birthday"] as! String
        self.dictParams["gender"] = dictInfo["gender"] as! String
        self.dictParams["address"] = dictInfo["address"] as! String
        self.dictParams["email"] = dictInfo["email"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLS3PPS.stringByAppendingString(WebServiceFor.ValidateVirtualCard.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.ValidateVirtualCard),
            "url" : urlLS3PPS]
        self.postWithDictionary(dictWebService)
    }
    
    func connectAndGetDashboardInfo(dictInfo: NSDictionary) {
        self.dictParams = NSMutableDictionary()
        self.dictParams["transactionId"] = dictInfo["transactionId"] as! String
        self.dictParams["mobileNumber"] = dictInfo["mobileNumber"] as! String
        
        let dictWebService = ["soapAction" : self.strSoapActionLS3PPS.stringByAppendingString(WebServiceFor.GetDashboardInfo.rawValue),
            "soapMessage" : self.getSoapMessageWithWebServiceFor(.GetDashboardInfo),
            "url" : urlLS3PPS]
        self.postWithDictionary(dictWebService)
    }
    
    //MARK: - NSURLConnection Delegate
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.mutableData.appendData(data)
        
        self.stopLossTimer()
        self.startLossTimer()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.stopLossTimer()
        
        //parse here
        self.xmlParser.data = self.mutableData
        self.xmlParser.request = self.request!
        self.xmlParser.parse()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.stopLossTimer()
        self._mutableData = nil
        
        self.delegate?.webServiceDidFailWithError(error)
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            return true
        }
        
        return false
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if self.trustedHosts.contains(challenge.protectionSpace.host) {
                challenge.sender!.useCredential(NSURLCredential(trust: challenge.protectionSpace.serverTrust!), forAuthenticationChallenge: challenge)
            }
        }
        
        challenge.sender?.continueWithoutCredentialForAuthenticationChallenge(challenge)
    }
    
    //MARK: - XMLParser Delegate
    
    func xmlParserDidFinish(parsedDictionary: NSDictionary) {
        self.delegate?.webServiceDidFinishLoadingWithResponseDictionary(parsedDictionary)
        
        self._mutableData = nil
    }
    
}
