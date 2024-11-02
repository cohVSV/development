<!--ASPX page @1-47460EDD-->
    <%@ Page language="vb" CodeFile="Student_ClassList_ExportCSV.aspx.vb" AutoEventWireup="false" Inherits="DECV_PROD2007.services.Student_ClassList_ExportCSV.Student_ClassList_ExportCSVPage" %>
	
	<%@ Import namespace="DECV_PROD2007.services.Student_ClassList_ExportCSV" %>
    <%@ Import namespace="DECV_PROD2007.Configuration" %>
    <%@ Import namespace="DECV_PROD2007.Data" %>
    
    <%@Register TagPrefix="CC" Namespace="DECV_PROD2007.Controls" %>

<asp:repeater id="view_Class_Contact_List_0Repeater" OnItemCommand="view_Class_Contact_List_0ItemCommand" OnItemDataBound="view_Class_Contact_List_0ItemDataBound" runat="server">
  <HeaderTemplate>
	"STUDENT ID","SURNAME","FIRST NAME","LAd","Current Phone Number","Current Email Address"," Postal Phone Number","Postal Email Address","Subject Abbrev","Subject Enrol Date","HOME SCHOOL","School Supervisor Name","School Supervisor Phone","School Supervisor Email","Staff ID","Parent Name","Parent Mobile","Parent Home Phone","Parent Email","Enrol Date","Year Level"

  </HeaderTemplate>
  <ItemTemplate>"<asp:Literal id="view_Class_Contact_List_0STUDENT_ID" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).STUDENT_ID.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0Alert" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).Alert.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SURNAME" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SURNAME.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0FIRST_NAME" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).FIRST_NAME.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0LAd" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).LAd.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PHONE1" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PHONE1.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0EMAIL1" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).EMAIL1.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PHONE2" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PHONE2.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0EMAIL2" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).EMAIL2.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SUBJECT_ABBREV" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SUBJECT_ABBREV.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SUBJ_ENROL_STATUS" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SUBJ_ENROL_STATUS.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SCHOOL_NAME" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SCHOOL_NAME.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SCHOOL_SUPERVISOR_NAME" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SCHOOL_SUPERVISOR_NAME.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SCHOOL_SUPERVISOR_PHONE" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SCHOOL_SUPERVISOR_PHONE.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0SCHOOL_SUPERVISOR_EMAIL" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).SCHOOL_SUPERVISOR_EMAIL.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0STAFF_ID" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).STAFF_ID.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PARENT_A_NAME" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PARENT_A_NAME.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PARENT_A_MOBILE" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PARENT_A_MOBILE.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PARENT_A_HOMEPHONE" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PARENT_A_HOMEPHONE.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0PARENT_A_EMAIL" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).PARENT_A_EMAIL.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0ENROLMENT_DATE" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).ENROLMENT_DATE.GetFormattedValue() %>' runat="server"/>","<asp:Literal id="view_Class_Contact_List_0YEAR_LEVEL" Text='<%# (CType(Container.DataItem,view_Class_Contact_List_0Item)).YEAR_LEVEL.GetFormattedValue() %>' runat="server"/>"
	<asp:PlaceHolder id="IterationContainer" runat="server"/>
  </ItemTemplate>
  <SeparatorTemplate>
	

  </SeparatorTemplate>
  <FooterTemplate>
	
[End of Class List]
  </FooterTemplate>
</asp:repeater>









<!--End ASPX page-->

