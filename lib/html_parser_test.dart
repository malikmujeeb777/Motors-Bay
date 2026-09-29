import 'package:html/parser.dart' as parser;

void main() {
  // Parse HTML
  final document = parser.parse(htmlContent);
  
  // Debug print with clear formatting
  print('\n=== HTML PARSER DEBUG OUTPUT ===\n');
  
  print('📄 HTML Content:');
  print('----------------------------------------');
  print(htmlContent);
  print('----------------------------------------\n');

  // Get all elements first
  final allElements = document.querySelectorAll('.sec2-data');
  
  // Debug print all found elements
  print('🔍 Found Elements:');
  print('----------------------------------------');
  allElements.asMap().forEach((index, element) {
    print('[$index] ${element.text.trim()}');
  });
  print('----------------------------------------\n');

  // Extract data using array indices since we know the order
  // Owner Details
  final ownerName = allElements[0]?.text.trim() ?? 'Not Available';
  final fatherHusbandName = allElements[1]?.text.trim() ?? 'Not Available';
  final ownerCity = allElements[2]?.text.trim() ?? 'Not Available';

  // Payment Details
  final paymentDate = allElements[3]?.text.trim() ?? 'Not Available';
  final paymentAmount = allElements[4]?.text.trim() ?? 'Not Available';
  final paymentType = allElements[5]?.text.trim() ?? 'Not Available';

  // Vehicle Details
  final engineNumber = allElements[6]?.text.trim() ?? 'Not Available';
  final makeName = allElements[7]?.text.trim() ?? 'Not Available';
  final registrationDate = allElements[8]?.text.trim() ?? 'Not Available';
  final yearOfManufacture = allElements[9]?.text.trim() ?? 'Not Available';
  final vehiclePrice = allElements[10]?.text.trim() ?? 'Not Available';
  final color = allElements[11]?.text.trim() ?? 'Not Available';
  final token = allElements[12]?.text.trim() ?? 'Not Available';

  // Application Tracking
  final applicationType = allElements[13]?.text.trim() ?? 'Not Available';
  final applicationStatus = allElements[14]?.text.trim() ?? 'Not Available';

  // Debug print extracted values by section
  print('📋 Extracted Values:');
  print('----------------------------------------');
  
  print('👤 Owner Details:');
  print('  • Name: $ownerName');
  print('  • Father/Husband: $fatherHusbandName');
  print('  • City: $ownerCity\n');
  
  print('💰 Payment Details:');
  print('  • Date: $paymentDate');
  print('  • Amount: $paymentAmount');
  print('  • Type: $paymentType\n');
  
  print('🚗 Vehicle Details:');
  print('  • Engine: $engineNumber');
  print('  • Make: $makeName');
  print('  • Reg Date: $registrationDate');
  print('  • Year: $yearOfManufacture');
  print('  • Price: $vehiclePrice');
  print('  • Color: $color');
  print('  • Token: $token\n');
  
  print('📊 Application Tracking:');
  print('  • Type: $applicationType');
  print('  • Status: $applicationStatus');
  print('----------------------------------------\n');
}

// HTML content string
const String htmlContent = '''
    <div class="col-lg-7 d-flex align-items-stretch flex-column align-items-center justify-content-center">
                <div class="card bor-rad-20 pad-25 w-100">
                            <div class="card-body  align-items-center justify-content-center">
                                <div class="row">
                                    <div class="col-md-12 print-logo-area">
                                        <img src="https://mtmis.excise.punjab.gov.pk/assets/img/print-logo-excise.svg" class="print-logo">
                                    </div>
                                </div>
                                <div class="row">
                                    <span>&nbsp;</span>

                                    <div class="col-lg-7 col-md-6 col-sm-6 mb-2 main-head-print">
                                        <h4 class="sec2-head">Vehicle Verification</h4>
                                    </div>

                                    <div class="col-lg-5 col-md-6 col-sm-6 mb-2">
                                        <p class="m-0 float-lg-start float-sm-end print-reg-num">
                                            <span class="sec2-head2">Registration Number</span>
                                            <span class="sec2-txt text-uppercase">AHE 080</span>
                                        </p>
                                    </div>
                                  
                                    <div class="col-md-7 mb-2">
                                        <a href="#" class="btn btn-print float-end px-3" onclick="print()"><img src="assets/img/icons/print.svg" class="me-1" alt="">Print</a>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-12 mb-2">
                                        <h4 class="sec2-sub-heads">
                                            <span class="sec2-icon-bg"><img src="assets/img/icons/owner.svg" alt=""></span>
                                            Owners Details
                                        </h4>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Owner Name</label>
                                        <p class="sec2-data">ALI SUBHANI</p>
                                    </div>


                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Father/Husband Name</label>
                                        <p class="sec2-data">IFTIKHAR AHMED</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Owner city</label>
                                        <p class="sec2-data">LAHORE</p>
                                    </div>
                                                                        <hr>

                                    <div class="col-md-12 mb-2">
                                        <h4 class="sec2-sub-heads">
                                            <span class="sec2-icon-bg"><img src="assets/img/icons/payment.svg" alt=""></span>
                                            Latest Payment Details
                                        </h4>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Date</label>
                                        <p class="sec2-data">17-Mar-2025</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Amount</label>
                                        <p class="sec2-data">28,050</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Payment Type</label>
                                        <p class="sec2-data">TRANSFER OF OWNERSHIP</p>
                                    </div>

                                    <hr>

                                    <div class="col-md-12 mb-2">
                                        <h4 class="sec2-sub-heads">
                                            <span class="sec2-icon-bg"><img src="assets/img/icons/details.svg" alt=""></span>
                                            Vehicle Details
                                        </h4>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Engine Number</label>
                                        <p class="sec2-data">KFJ721252</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Make Name</label>
                                        <p class="sec2-data">DAIHATSU        - CAST</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Registration Date</label>
                                        <p class="sec2-data">2022-02-22 </p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Year of Manufacture</label>
                                        <p class="sec2-data">2018</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Vehicle Price</label>
                                        <p class="sec2-data">1,250,000</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Color</label>
                                        <p class="sec2-data">MEHROON</p>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                                                                <label class="sec2-lable" for="">Token</label>
                                        <p class="sec2-data">Life Time</p>
                                    </div>

                                    <hr>
                                    <span>&nbsp;</span>
                                    <span>&nbsp;</span>

                                    <div class="col-md-12 mb-2">
                                        <h4 class="sec2-sub-heads">
                                            <span class="sec2-icon-bg"><img src="assets/img/icons/tracking.svg" alt=""></span>
                                            Vehicle Application Tracking
                                        </h4>
                                    </div>

                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Application Type:</label>
                                        <p class="sec2-data">TRANSFER OF OWNERSHIP</p>
                                    </div>
                                    <div class="col-md-4 mb-2">
                                        <label class="sec2-lable" for="">Application Current Status:</label>
                                        <p class="sec2-data">DELIVERED</p>
                                    </div>


                                </div>
                            </div>
                        </div>
                    </div>
            </div>
'''; 