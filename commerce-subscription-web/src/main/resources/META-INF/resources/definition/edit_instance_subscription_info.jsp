<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/init.jsp" %>

<%
CPInstanceSubscriptionInfoDisplayContext cpInstanceSubscriptionInfoDisplayContext = (CPInstanceSubscriptionInfoDisplayContext)request.getAttribute(WebKeys.PORTLET_DISPLAY_CONTEXT);

CPDefinition cpDefinition = cpInstanceSubscriptionInfoDisplayContext.getCPDefinition();
CPInstance cpInstance = cpInstanceSubscriptionInfoDisplayContext.getCPInstance();
long cpInstanceId = cpInstanceSubscriptionInfoDisplayContext.getCPInstanceId();
List<CPSubscriptionType> cpSubscriptionTypes = cpInstanceSubscriptionInfoDisplayContext.getCPSubscriptionTypes();

String defaultCPSubscriptionType = StringPool.BLANK;

if (!cpSubscriptionTypes.isEmpty()) {
	CPSubscriptionType firstCPSubscriptionType = cpSubscriptionTypes.get(0);

	defaultCPSubscriptionType = firstCPSubscriptionType.getName();
}

PortletURL productSkusURL = renderResponse.createRenderURL();

productSkusURL.setParameter("mvcRenderCommandName", "editProductDefinition");
productSkusURL.setParameter("cpDefinitionId", String.valueOf(cpDefinition.getCPDefinitionId()));
productSkusURL.setParameter("screenNavigationCategoryKey", cpInstanceSubscriptionInfoDisplayContext.getScreenNavigationCategoryKey());

boolean overrideSubscriptionInfo = BeanParamUtil.getBoolean(cpInstance, request, "overrideSubscriptionInfo", false);
boolean subscriptionEnabled = BeanParamUtil.getBoolean(cpInstance, request, "subscriptionEnabled", false);
int subscriptionLength = BeanParamUtil.getInteger(cpInstance, request, "subscriptionLength", 1);
String subscriptionType = BeanParamUtil.getString(cpInstance, request, "subscriptionType", defaultCPSubscriptionType);
long maxSubscriptionCycles = BeanParamUtil.getLong(cpInstance, request, "maxSubscriptionCycles");

String defaultCPSubscriptionTypeLabel = StringPool.BLANK;

CPSubscriptionType cpSubscriptionType = cpInstanceSubscriptionInfoDisplayContext.getCPSubscriptionType(subscriptionType);

if (cpSubscriptionType != null) {
	defaultCPSubscriptionTypeLabel = cpSubscriptionType.getLabel(locale);
}

CPSubscriptionTypeJSPContributor cpSubscriptionTypeJSPContributor = cpInstanceSubscriptionInfoDisplayContext.getCPSubscriptionTypeJSPContributor(subscriptionType);

boolean ending = maxSubscriptionCycles > 0;
%>

<aui:alert closeable="<%= false %>" cssClass="mt-3" type="warning">
	<liferay-ui:message key="all-channels-associated-with-this-product-must-have-at-least-one-payment-method-active-that-supports-recurring-payments" />
</aui:alert>

<portlet:actionURL name="editProductInstance" var="editProductInstanceShippingInfoActionURL" />

<aui:form action="<%= editProductInstanceShippingInfoActionURL %>" cssClass="container-fluid-1280" method="post" name="fm">
	<aui:input name="<%= Constants.CMD %>" type="hidden" value="updateSubscriptionInfo" />
	<aui:input name="redirect" type="hidden" value="<%= String.valueOf(cpInstanceSubscriptionInfoDisplayContext.getPortletURL()) %>" />
	<aui:input name="cpInstanceId" type="hidden" value="<%= cpInstanceId %>" />

	<aui:model-context bean="<%= cpInstance %>" model="<%= CPInstance.class %>" />

	<aui:fieldset-group markupView="lexicon">
		<aui:fieldset>
			<aui:input checked="<%= overrideSubscriptionInfo %>" label="override-subscription-settings" name="overrideSubscriptionInfo" type="toggle-switch" value="<%= overrideSubscriptionInfo %>" />

		<div class="<%= overrideSubscriptionInfo ? StringPool.BLANK : "hide" %>" id="<portlet:namespace />subscriptionInfo">
			<aui:input checked="<%= subscriptionEnabled %>" label="enable-subscription" name="subscriptionEnabled" type="toggle-switch" value="<%= subscriptionEnabled %>" />

			<div class="<%= subscriptionEnabled ? StringPool.BLANK : "hide" %>" id="<portlet:namespace />subscriptionOptions">
				<aui:select name="subscriptionType" onChange='<%= renderResponse.getNamespace() + "selectSubscriptionType();" %>'>

					<%
					for (CPSubscriptionType curCPSubscriptionType : cpSubscriptionTypes) {
					%>

						<aui:option data-label="<%= curCPSubscriptionType.getLabel(locale) %>" label="<%= curCPSubscriptionType.getLabel(locale) %>" selected="<%= subscriptionType.equals(curCPSubscriptionType.getName()) %>" value="<%= curCPSubscriptionType.getName() %>" />

					<%
					}
					%>

				</aui:select>

			<%
			if (cpSubscriptionTypeJSPContributor != null) {
				cpSubscriptionTypeJSPContributor.render(cpInstance, request, PipingServletResponse.createPipingServletResponse(pageContext));
			}
			%>

			<div id="<portlet:namespace />cycleLengthContainer">
				<aui:input name="subscriptionLength" suffix="<%= defaultCPSubscriptionTypeLabel %>" value="<%= String.valueOf(subscriptionLength) %>">
					<aui:validator name="digits" />
					<aui:validator name="min">1</aui:validator>
				</aui:input>
			</div>

			<div id="<portlet:namespace />neverEndsContainer">
					<div class="never-ends-header">
						<aui:input checked="<%= ending ? false : true %>" name="neverEnds" type="toggle-switch" />
					</div>

					<div class="never-ends-content">
						<aui:input disabled="<%= ending ? false : true %>" helpMessage="max-subscription-cycles-help" label="end-after" name="maxSubscriptionCycles" suffix='<%= LanguageUtil.get(request, "cycles") %>' value="<%= String.valueOf(maxSubscriptionCycles) %>">
							<aui:validator name="digits" />

							<aui:validator errorMessage='<%= LanguageUtil.format(request, "please-enter-a-value-greater-than-or-equal-to-x", 1) %>' name="custom">
								function(val, fieldNode, ruleValue) {
									if (AUI.$('#<portlet:namespace />neverEnds')[0].checked) {
										return true;
									}

									if (parseInt(val, 10) > 0) {
										return true;
									}

									return false;
								}
							</aui:validator>
						</aui:input>
					</div>
				</div>
		</aui:fieldset>
	</aui:fieldset-group>

		<aui:button-row>
			<aui:button cssClass="btn-lg" type="submit" />

			<aui:button cssClass="btn-lg" href="<%= productSkusURL.toString() %>" type="cancel" />
		</aui:button-row>
</aui:form>

<aui:script>
	Liferay.Util.toggleBoxes('<portlet:namespace />overrideSubscriptionInfo', '<portlet:namespace />subscriptionInfo');

	Liferay.Util.toggleBoxes('<portlet:namespace />subscriptionEnabled', '<portlet:namespace />subscriptionOptions');

	Liferay.provide(
		window,
		'<portlet:namespace />selectSubscriptionType',
			function() {
			var A = AUI();

			var overrideSubscriptionInfo = A.one('#<portlet:namespace />overrideSubscriptionInfo').attr('checked');
			var subscriptionEnabled = A.one('#<portlet:namespace />subscriptionEnabled').attr('checked');
			var subscriptionLength = A.one('#<portlet:namespace />subscriptionLength').val();
			var subscriptionType = A.one('#<portlet:namespace />subscriptionType').val();
			var maxSubscriptionCycles = A.one('#<portlet:namespace />maxSubscriptionCycles').val();

			var portletURL = new Liferay.PortletURL.createURL('<%= currentURLObj %>');

			portletURL.setParameter('overrideSubscriptionInfo', overrideSubscriptionInfo);
			portletURL.setParameter('subscriptionEnabled', subscriptionEnabled);
			portletURL.setParameter('subscriptionLength', subscriptionLength);
			portletURL.setParameter('subscriptionType', subscriptionType);
			portletURL.setParameter('maxSubscriptionCycles', maxSubscriptionCycles);

			window.location.replace(portletURL.toString());
		},
		['liferay-portlet-url']
	);
</aui:script>

<aui:script use="liferay-form">
	A.one('#<portlet:namespace />neverEnds').on(
	'change',
		function(event) {
			var formValidator = Liferay.Form.get('<portlet:namespace />fm').formValidator;

			formValidator.validateField('<portlet:namespace />maxSubscriptionCycles');
		}
	);
</aui:script>

<aui:script use="aui-toggler">
	new A.Toggler(
		{
			animated: true,
			content: '#<portlet:namespace />neverEndsContainer .never-ends-content',
			expanded: <%= ending %>,
			header: '#<portlet:namespace />neverEndsContainer .never-ends-header',
			on: {
				animatingChange: function(event) {
					var instance = this;

					if (!instance.get('expanded')) {
						A.one('#<portlet:namespace />maxSubscriptionCycles').attr('disabled', false);
					}
					else {
						A.one('#<portlet:namespace />maxSubscriptionCycles').attr('disabled', true);
					}
				}
			}
		}
	);
</aui:script>