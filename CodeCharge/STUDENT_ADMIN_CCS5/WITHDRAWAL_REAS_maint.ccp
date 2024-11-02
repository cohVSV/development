<Page id="1" templateExtension="html" relativePath="." fullRelativePath="." secured="False" urlType="Relative" isIncluded="False" SSLAccess="False" cachingEnabled="False" validateRequest="True" cachingDuration="1 minutes" wizardTheme="Blueprint" wizardThemeVersion="3.0" needGeneration="0" isService="False">
	<Components>
		<Record id="2" sourceType="Table" urlType="Relative" secured="False" allowInsert="True" allowUpdate="True" allowDelete="True" validateData="True" preserveParameters="GET" returnValueType="Number" returnValueTypeForDelete="Number" returnValueTypeForInsert="Number" returnValueTypeForUpdate="Number" connection="connDECVPRODSQL2005" name="WITHDRAWAL_REASON" dataSource="WITHDRAWAL_REASON" errorSummator="Error" wizardCaption="Add/Edit WITHDRAWAL REASON " wizardFormMethod="post" returnPage="WITHDRAWAL_REAS_list.ccp" PathID="WITHDRAWAL_REASON">
			<Components>
				<Button id="3" urlType="Relative" enableValidation="True" isDefault="False" name="Button_Insert" operation="Insert" wizardCaption="Add" PathID="WITHDRAWAL_REASONButton_Insert">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</Button>
				<Button id="4" urlType="Relative" enableValidation="True" isDefault="False" name="Button_Update" operation="Update" wizardCaption="Submit" PathID="WITHDRAWAL_REASONButton_Update">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</Button>
				<Button id="5" urlType="Relative" enableValidation="False" isDefault="False" name="Button_Delete" operation="Delete" wizardCaption="Delete" PathID="WITHDRAWAL_REASONButton_Delete">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</Button>
				<TextBox id="7" visible="Yes" fieldSourceType="DBColumn" dataType="Text" name="WITHDRAWAL_REASON" fieldSource="WITHDRAWAL_REASON" required="True" caption="WITHDRAWAL REASON" wizardCaption="WITHDRAWAL REASON" wizardSize="30" wizardMaxLength="30" wizardIsPassword="False" PathID="WITHDRAWAL_REASONWITHDRAWAL_REASON">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</TextBox>
				<CheckBox id="8" visible="Yes" fieldSourceType="DBColumn" dataType="Boolean" name="STATUS" fieldSource="STATUS" required="True" caption="STATUS" wizardCaption="STATUS" wizardSize="1" wizardMaxLength="1" wizardIsPassword="False" PathID="WITHDRAWAL_REASONSTATUS" defaultValue="Unchecked">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</CheckBox>
				<TextBox id="9" visible="Yes" fieldSourceType="DBColumn" dataType="Text" name="LAST_ALTERED_BY" fieldSource="LAST_ALTERED_BY" required="True" caption="LAST ALTERED BY" wizardCaption="LAST ALTERED BY" wizardSize="8" wizardMaxLength="8" wizardIsPassword="False" PathID="WITHDRAWAL_REASONLAST_ALTERED_BY">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</TextBox>
				<TextBox id="10" visible="Yes" fieldSourceType="DBColumn" dataType="Date" name="LAST_ALTERED_DATE" fieldSource="LAST_ALTERED_DATE" required="True" caption="LAST ALTERED DATE" wizardCaption="LAST ALTERED DATE" wizardSize="10" wizardMaxLength="100" wizardIsPassword="False" PathID="WITHDRAWAL_REASONLAST_ALTERED_DATE">
					<Components/>
					<Events/>
					<Attributes/>
					<Features/>
				</TextBox>
			</Components>
			<Events/>
			<TableParameters>
				<TableParameter id="6" conditionType="Parameter" useIsNull="False" field="WITHDRAWAL_REASON_ID" parameterSource="WITHDRAWAL_REASON_ID" dataType="Float" logicOperator="And" searchConditionType="Equal" parameterType="URL" orderNumber="1"/>
			</TableParameters>
			<SPParameters/>
			<SQLParameters/>
			<JoinTables/>
			<JoinLinks/>
			<Fields/>
			<ISPParameters/>
			<ISQLParameters/>
			<IFormElements/>
			<USPParameters/>
			<USQLParameters/>
			<UConditions/>
			<UFormElements/>
			<DSPParameters/>
			<DSQLParameters/>
			<DConditions/>
			<SecurityGroups/>
			<Attributes/>
			<Features/>
			<PKFields/>
		</Record>
		<IncludePage id="11" name="Header" page="Header.ccp">
			<Components/>
			<Events/>
			<Features/>
		</IncludePage>
		<IncludePage id="12" name="Footer" page="Footer.ccp">
			<Components/>
			<Events/>
			<Features/>
		</IncludePage>
	</Components>
	<CodeFiles>
		<CodeFile id="3" language="VB" name="WITHDRAWAL_REAS_maint.aspx" forShow="True" url="WITHDRAWAL_REAS_maint.aspx" comment="&lt;!--" commentEnd="--&gt;" codePage="windows-1252"/>
		<CodeFile id="1" language="VB" name="WITHDRAWAL_REAS_maint.aspx.vb" forShow="False" comment="'" codePage="windows-1252"/>
		<CodeFile id="2" language="VB" name="WITHDRAWAL_REAS_maintDataProvider.vb" path=".\App_Code\." forShow="False" comment="'" codePage="windows-1252"/>
	</CodeFiles>
	<SecurityGroups/>
	<CachingParameters/>
	<Attributes/>
	<Features/>
	<Events/>
</Page>
