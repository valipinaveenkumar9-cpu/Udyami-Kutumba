import 'package:flutter/material.dart';
import '../../../core/api/ubn/udyami_member_api.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_profile_model.dart';
import 'package:udyamikutumba/core/widgets/theme_toggle_button.dart';

class UdyamiMemberFormScreen extends StatefulWidget {
  final Map<String, dynamic> existingData;
  final UserModel? currentUser;
  final UserProfileModel? fullProfile;

  const UdyamiMemberFormScreen({
    super.key,
    this.existingData = const {},
    this.currentUser,
    this.fullProfile,
  });

  @override
  State<UdyamiMemberFormScreen> createState() => _UdyamiMemberFormScreenState();
}

class _UdyamiMemberFormScreenState extends State<UdyamiMemberFormScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.existingData);
    
    if (widget.currentUser != null) {
      if (!_formData.containsKey('fullName') || _formData['fullName'] == null || _formData['fullName'].isEmpty) {
        _formData['fullName'] = widget.currentUser!.name;
      }
      if (!_formData.containsKey('email') || _formData['email'] == null || _formData['email'].isEmpty) {
        _formData['email'] = widget.currentUser!.email;
      }
      if (!_formData.containsKey('primaryMobile') || _formData['primaryMobile'] == null || _formData['primaryMobile'].isEmpty) {
        _formData['primaryMobile'] = widget.currentUser!.mobileNumber;
      }
    }
    
    if (widget.fullProfile != null) {
      final p = widget.fullProfile!.profile;
      void prefill(String key, dynamic value) {
        if ((!_formData.containsKey(key) || _formData[key] == null || _formData[key] == '') && value != null && value != '') {
          _formData[key] = value;
        }
      }
      prefill('gender', p.gender);
      prefill('currentAddress', p.homeAddress);
      prefill('state', p.state);
      prefill('pincode', p.pincode);
      prefill('ownBusiness', p.hasBusiness);
      prefill('district', p.district);
      prefill('ward', p.ward);
      
      if (p.businessDetails != null) {
        prefill('industrySector', p.businessDetails!.businessType);
        prefill('businessName', p.businessDetails!.businessName);
      }
    }
  }

  void _onStepContinue() {
    if (_currentStep < 6) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _isLoading = true);
    
    if (widget.currentUser != null) {
      _formData['createdByUserId'] = widget.currentUser!.userId;
    }
    
    // Convert array strings back to lists
    final listFields = ['languagesKnown', 'geographicMarkets', 'salesChannels', 'onlineSalesChannels', 'certifications', 'professionalSkills', 'interests', 'tags', 'homeBusinessInterests', 'interestedSectors', 'socialPlatformsUsed'];
    for (String field in listFields) {
      if (_formData[field] is String) {
        _formData[field] = (_formData[field] as String).split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }

    // Convert number strings back to numbers
    final numberFields = ['yearEstablished', 'noOfEmployees', 'yearsOfExperience', 'graduationYear', 'weeklyHours', 'followers'];
    for (String field in numberFields) {
      if (_formData[field] is String) {
        _formData[field] = int.tryParse(_formData[field]) ?? 0;
      }
    }

    final isUpdate = widget.existingData.isNotEmpty && widget.existingData.containsKey('udyamiMemberId');
    final success = isUpdate 
        ? await UdyamiMemberAPI.updateUdyamiMember(widget.existingData['udyamiMemberId'], _formData)
        : await UdyamiMemberAPI.createUdyamiMember(_formData);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Udyami Member Profile Updated!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }

  Widget _buildTextField(String label, String key, {TextInputType type = TextInputType.text}) {
    String initial = '';
    if (_formData[key] is List) {
      initial = (_formData[key] as List).join(', ');
    } else {
      initial = _formData[key]?.toString() ?? '';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initial,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: type,
        onChanged: (val) {
          _formData[key] = val;
        },
      ),
    );
  }

  Widget _buildSwitch(String label, String key) {
    bool val = _formData[key] == true || _formData[key] == 'true';
    return SwitchListTile(
      title: Text(label),
      value: val,
      onChanged: (newVal) {
        setState(() {
          _formData[key] = newVal;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
            actions: const [ThemeToggleButton()],
            title: Text(widget.existingData.isNotEmpty ? 'Update Udyami Profile' : 'Become an Udyami Member'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            physics: const ClampingScrollPhysics(),
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            onStepTapped: (step) => setState(() => _currentStep = step),
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              final isLastStep = _currentStep == 6; // 6 is the last step index
              final isUpdate = widget.existingData.isNotEmpty && widget.existingData.containsKey('udyamiMemberId');
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLastStep ? (isUpdate ? 'Update' : 'Register') : 'Continue'),
                    ),
                    const SizedBox(width: 12),
                    if (_currentStep != 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Personal Details'),
                isActive: _currentStep >= 0,
                content: Column(
                  children: [
                    _buildTextField('Full Name', 'fullName'),
                    _buildTextField('Last Name', 'lastName'),
                    _buildTextField('Father Name', 'fatherName'),
                    _buildTextField('Mother Name', 'motherName'),
                    _buildTextField('Date of Birth', 'dateOfBirth'),
                    _buildTextField('Gender', 'gender'),
                    _buildTextField('Marital Status', 'maritalStatus'),
                    _buildTextField('Primary Mobile', 'primaryMobile', type: TextInputType.phone),
                    _buildTextField('WhatsApp Number', 'whatsappNumber', type: TextInputType.phone),
                    _buildTextField('Email', 'email', type: TextInputType.emailAddress),
                    _buildTextField('Preferred Channel', 'preferredChannel'),
                    _buildTextField('Preferred Language', 'preferredLanguage'),
                    _buildTextField('Languages Known (comma separated)', 'languagesKnown'),
                    _buildTextField('Blood Group', 'bloodGroup'),
                    _buildTextField('Education', 'education'),
                    _buildTextField('Family Income', 'familyIncome'),
                    _buildTextField('Emergency Contact Name', 'emergencyContactName'),
                    _buildTextField('Emergency Phone', 'emergencyPhone', type: TextInputType.phone),
                    _buildTextField('Relationship', 'relationship'),
                    _buildTextField('Gov ID Type', 'govIdType'),
                    _buildTextField('Gov ID Number', 'govIdNumber'),
                  ],
                ),
              ),
              Step(
                title: const Text('Address Details'),
                isActive: _currentStep >= 1,
                content: Column(
                  children: [
                    _buildTextField('Current Address', 'currentAddress'),
                    _buildTextField('Permanent Address', 'permanentAddress'),
                    _buildTextField('Area', 'ward'),
                    _buildTextField('Circle', 'circle'),
                    _buildTextField('State', 'state'),
                    _buildTextField('Pincode', 'pincode', type: TextInputType.number),
                  ],
                ),
              ),
              Step(
                title: const Text('Business Profile'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    _buildSwitch('Own a Business?', 'ownBusiness'),
                    _buildTextField('Business Name', 'businessName'),
                    _buildTextField('Business Type', 'businessType'),
                    _buildTextField('Industry Sector', 'industrySector'),
                    _buildTextField('Sub Category', 'subCategory'),
                    _buildTextField('Business Stage', 'businessStage'),
                    _buildTextField('Year Established', 'yearEstablished', type: TextInputType.number),
                    _buildTextField('Annual Turnover', 'annualTurnover'),
                    _buildTextField('Number of Employees', 'noOfEmployees', type: TextInputType.number),
                    _buildSwitch('GST Registration', 'gstRegistration'),
                    _buildTextField('GST Number', 'gstNumber'),
                    _buildSwitch('MSME Registration', 'msmeRegistration'),
                    _buildTextField('Target Customer', 'targetCustomer'),
                    _buildTextField('Geographic Markets (comma separated)', 'geographicMarkets'),
                    _buildTextField('Sales Channels (comma separated)', 'salesChannels'),
                    _buildSwitch('Sells Online?', 'sellsOnline'),
                    _buildTextField('Online Sales Channels (comma separated)', 'onlineSalesChannels'),
                    _buildTextField('Business Website', 'businessWebsite'),
                    _buildSwitch('Bank Account for Business?', 'bankAccount'),
                    _buildTextField('Primary Products/Services', 'primaryProductsServices'),
                    _buildTextField('Biggest Challenges', 'biggestChallenges'),
                    _buildTextField('Support Needed', 'supportNeeded'),
                    _buildSwitch('Taken Business Loan?', 'takenBusinessLoan'),
                    _buildSwitch('Seeking Funding?', 'seekingFunding'),
                  ],
                ),
              ),
              Step(
                title: const Text('Skills & Interests'),
                isActive: _currentStep >= 3,
                content: Column(
                  children: [
                    _buildTextField('Field of Study', 'fieldOfStudy'),
                    _buildTextField('Certifications (comma separated)', 'certifications'),
                    _buildTextField('Skill Proficiency', 'skillProficiency'),
                    _buildTextField('Years of Experience', 'yearsOfExperience', type: TextInputType.number),
                    _buildSwitch('Sales Expertise?', 'salesExpertise'),
                    _buildSwitch('Digital Marketing?', 'digitalMarketing'),
                    _buildSwitch('Financial Skills?', 'financialSkills'),
                    _buildSwitch('IT/Tech Skills?', 'itTechSkills'),
                    _buildSwitch('Public Speaking?', 'publicSpeaking'),
                    _buildSwitch('Content Creation?', 'contentCreation'),
                    _buildSwitch('Culinary Skills?', 'culinarySkills'),
                    _buildSwitch('Art/Craft Skills?', 'artCraftSkills'),
                    _buildTextField('Professional Skills (comma separated)', 'professionalSkills'),
                    _buildTextField('Interests (comma separated)', 'interests'),
                    _buildSwitch('Want New Skills?', 'wantNewSkills'),
                    _buildSwitch('Willing to Mentor?', 'willingToMentor'),
                    _buildSwitch('Open to Collaborate?', 'openToCollaborate'),
                    _buildTextField('Tags (comma separated)', 'tags'),
                  ],
                ),
              ),
              Step(
                title: const Text('Homemaker & Student'),
                isActive: _currentStep >= 4,
                content: Column(
                  children: [
                    _buildSwitch('Homemaker?', 'homemaker'),
                    _buildSwitch('Want Home Business?', 'wantHomeBusiness'),
                    _buildSwitch('Relevant Experience?', 'relevantExperience'),
                    _buildTextField('Home Business Interests (comma separated)', 'homeBusinessInterests'),
                    _buildSwitch('Has Equipment?', 'hasEquipment'),
                    _buildSwitch('Dark Store Interest?', 'darkStoreInterest'),
                    _buildSwitch('Final Year Student?', 'finalYearStudent'),
                    _buildTextField('Course/Degree', 'courseDegree'),
                    _buildTextField('Institution', 'institution'),
                    _buildTextField('Graduation Year', 'graduationYear', type: TextInputType.number),
                    _buildSwitch('Interested in Entrepreneurship?', 'interestedInEntrepreneurship'),
                    _buildSwitch('Has Business Idea?', 'hasBusinessIdea'),
                    _buildTextField('Interested Sectors (comma separated)', 'interestedSectors'),
                    _buildSwitch('Startup Competitions?', 'startupCompetitions'),
                    _buildSwitch('Financial Support?', 'financialSupport'),
                    _buildTextField('Business Idea Description', 'businessIdeaDescription'),
                    _buildTextField('Problem To Solve', 'problemToSolve'),
                  ],
                ),
              ),
              Step(
                title: const Text('Digital Readiness'),
                isActive: _currentStep >= 5,
                content: Column(
                  children: [
                    _buildSwitch('Existing Customers?', 'existingCustomers'),
                    _buildSwitch('Product Support?', 'productSupport'),
                    _buildSwitch('Comfortable Online?', 'comfortableOnline'),
                    _buildSwitch('Has Smartphone?', 'hasSmartphone'),
                    _buildTextField('Training Availability', 'trainingAvailability'),
                    _buildTextField('Monthly Income Target', 'monthlyIncomeTarget'),
                    _buildSwitch('Want Mentor?', 'wantMentor'),
                    _buildSwitch('Willing to Mentor Women?', 'willingToMentorWomen'),
                    _buildSwitch('Work with Businesses?', 'workWithBusinesses'),
                    _buildTextField('Weekly Hours', 'weeklyHours', type: TextInputType.number),
                    _buildSwitch('Tech Skills?', 'techSkills'),
                    _buildTextField('Role Model', 'roleModel'),
                    _buildTextField('Social Platforms Used (comma separated)', 'socialPlatformsUsed'),
                    _buildTextField('Primary Platform', 'primaryPlatform'),
                    _buildTextField('Daily Usage', 'dailyUsage'),
                    _buildTextField('Followers', 'followers', type: TextInputType.number),
                    _buildTextField('Post Frequency', 'postFrequency'),
                    _buildSwitch('WhatsApp Business?', 'whatsappBusiness'),
                    _buildSwitch('Google My Business?', 'googleMyBusiness'),
                    _buildSwitch('Digital Payments?', 'digitalPayments'),
                    _buildSwitch('Procures Online?', 'procuresOnline'),
                    _buildSwitch('Create Content?', 'createContent'),
                    _buildTextField('Business Software', 'businessSoftware'),
                    _buildTextField('Smartphone Comfort', 'smartphoneComfort'),
                    _buildSwitch('Want Digital Marketing Training?', 'wantDigitalMarketingTraining'),
                  ],
                ),
              ),
              Step(
                title: const Text('Networking & Feedback'),
                isActive: _currentStep >= 6,
                content: Column(
                  children: [
                    _buildTextField('How Heard About Us', 'howHeardAboutUs'),
                    _buildTextField('Referrer Name', 'referrerName'),
                    _buildTextField('Referrer Udyami ID', 'referrerUdyamiId'),
                    _buildSwitch('Existing Association?', 'existingAssociation'),
                    _buildSwitch('Attends Networking?', 'attendsNetworking'),
                    _buildTextField('Known Businesses', 'knownBusinesses'),
                    _buildTextField('Biggest Opportunity In Area', 'biggestOpportunityInArea'),
                    _buildTextField('Infrastructure Challenges', 'infrastructureChallenges'),
                    _buildSwitch('Willing to Refer?', 'willingToRefer'),
                    _buildSwitch('Can Host Meeting?', 'canHostMeeting'),
                    _buildSwitch('Aware of Gov Schemes?', 'awareOfGovSchemes'),
                    _buildTextField('Unserved Business Needs', 'unservedBusinessNeeds'),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
