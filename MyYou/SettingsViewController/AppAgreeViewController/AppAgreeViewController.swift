//
//  AppAgreeViewController.swift
//  MyYou
//
//  Created by Youngmin Cho on 1/5/24.
//

import UIKit

class AppAgreeViewController: UIViewController {

    @IBOutlet weak var appAgreeTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appAgreeTextView.text = "\n" +
        "개인정보처리방침\n" +
        "본 앱서비스를 제공하는 회사(이하 ‘회사’라 한다)는 정보통신망 이용촉진 및 정보보호 등에 관한 법률, 개인정보보호법 등 관련 법령에 따라 이용자의 개인정보를 보호하고, 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보처리방침을 수립합니다. 회사는 앱설치시 고객의 동의를 받은 후에 아래와 같은 정보를 수집합니다. 처리하고 있는 개인정보는 다음의 수집·이용목적 이외의 용도로는 활용되지 않으며, 수집·이용목적이 변경되는 경우에는 개인정보보호법에 따라 별도의 동의를 받는 등 필요한 조치를 이행합니다.\n" +
        "수집하는 개인정보의 항목 및 수집방법\n" +
        "필수항목\n" +
        "- 휴대전화번호\n" +
        "\n" +
        "선택항목\n" +
        "- 없음\n" +
        "\n" +
        "기타\n" +
        "- 없음\n" +
        "\n" +
        "개인정보 수집방법\n" +
        "회사는 다음과 같은 방법으로 개인정보를 수집합니다.\n" +
        "\n" +
        "- 앱설치시 설치하는 기기의 휴대전화번호 자동 추출(설치시 고객의 동의를 받은 후에 설치 및 추출)\n" +
        "\n" +
        "'정보통신망 이용촉진 및 정보보호 등에 관한 법률'에 의거하여 고유식별번호(주민등록번호, 운전면허번호, 여권번호, 외국인등록증번호)는 수집하지 않습니다.\n" +
        "개인정보의 수집 및 이용목적\n" +
        "회사는 아래와 같은 목적으로 개인정보를 수집합니다.\n" +
        "서비스 제공을 위한 메시지 알림 및 기타 서비스제공에 따른 알림, 공지사항등 문자메세지 알림\n" +
        "서비스 안내등 마케팅 및 광고\n" +
        "- 신규 서비스 개발 및 특화, 서비스 제공 게재, 이벤트 등 광고성 정보 전달\n" +
        "\n" +
        "개인정보의 보유 및 이용기간\n" +
        "서비스 이용자가 당사의 앱서비스를 계속 이용하는 동안 당사는 이용자의 개인정보(휴대전화정보)를 계속 보유하며 문자메세지 알림을 위해 이용합니다.\n" +
        "서비스 이용자의 개인정보는 그 수집 및 이용 목적이 달성되거나 이용자의 요청이 있을 경우 재생할 수 없는 방법으로 파기됩니다.\n" +
        "당사는 이용자의 권리 남용, 악용 방지, 권리침해/명예훼손 분쟁 및 수사협조 등의 요청이 있었을 경우에는 이의 재발에 대비하여 회원의 이용계약 해지 시로부터 1년 동안 회원의 개인정보를 보관할 수 있습니다.\n" +
        "상법, 전자상거래 등에서의 소비자보호에 관한 법률 등 관계법령의 규정에 의하여 보존할 필요가 있는 경우 당사는 관계법령에서 정한 일정한 기간 동안 회원정보를 보관합니다. 이 경우 당사는 보관하는 정보를 그 보관의 목적으로만 이용하며 보존기간은 아래와 같습니다.\n" +
        "계약 또는 청약철회 등에 관한 기록\n" +
        "- 보존이유 : 전자상거래 등에서의 소비자보호에 관한 법률\n" +
        "\n" +
        "- 보존기간 : 5년\n" +
        "\n" +
        "대금결제 및 재화 등의 공급에 관한 기록\n" +
        "- 보존이유 : 전자상거래 등에서의 소비자보호에 관한 법률\n" +
        "\n" +
        "- 보존기간 : 5년\n" +
        "\n" +
        "소비자의 불만 및 분쟁처리에 관한 기록\n" +
        "- 보존이유 : 전자상거래 등에서의 소비자보호에 관한 법률\n" +
        "\n" +
        "- 보존기간 : 3년\n" +
        "\n" +
        "로그기록\n" +
        "- 보존이유 : 통신비밀보호법\n" +
        "\n" +
        "- 보존기간 : 3개월"
    }
}
