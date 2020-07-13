curl -k -c /tmp/vm_cookie --location --request POST 'https://<vCENTER_IP>/sdk/vimService.wsdl' \
--header 'Content-Type: application/xml' \
-d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vim25">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:Login>
         <urn:_this type="SessionManager">SessionManager</urn:_this>
         <urn:userName>USER</urn:userName>
         <urn:password>PASSWORD</urn:password>
      </urn:Login>
   </soapenv:Body>
</soapenv:Envelope>'

curl -k -b /tmp/vm_cookie --location --request POST 'https://<vCENTER_IP>/sdk/vimService.wsdl' \
--header 'Content-Type: text/xml;charset=UTF-8
SOAPAction: "urn:vim25/6.0"' \
-d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vim25">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:RetrieveProperties>
         <urn:_this type="PropertyCollector">propertyCollector</urn:_this>
         <urn:specSet>
            <urn:propSet>
               <urn:type>EventManager</urn:type>
               <urn:all>false</urn:all>
               <urn:pathSet>latestEvent</urn:pathSet>
            </urn:propSet>
            <urn:objectSet>
               <urn:obj type="EventManager">EventManager</urn:obj>
            </urn:objectSet>
         </urn:specSet>
      </urn:RetrieveProperties>
   </soapenv:Body>
</soapenv:Envelope>'

curl -k -b /tmp/vm_cookie --location --request POST 'https://<vCENTER_IP>/sdk/vimService.wsdl' \
--header 'Content-Type: application/xml' \
-d '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:vim25">
   <soapenv:Header/>
   <soapenv:Body>
      <urn:Logout>
         <urn:_this type="SessionManager">SessionManager</urn:_this>
      </urn:Logout>
   </soapenv:Body>
</soapenv:Envelope>'
