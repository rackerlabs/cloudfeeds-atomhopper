package com.rackspace.feeds.filter;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.StringReader;
import java.util.Collections;

/**
 * This filter extends the Xml2JsonFilter and modify the behavior to not use piped async call,
 * and to set the contentLength of the transformed response.
 *
 * It requires a Filter input parameter called 'xsltFile' which is the full path to the XSLT file to perform the
 * transformation.
 */
public class Xml2JsonNoStreamFilter extends Xml2JsonFilter {
    private static Logger LOG = LoggerFactory.getLogger(Xml2JsonNoStreamFilter.class);

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         final FilterChain chain)
            throws java.io.IOException, ServletException {

        LOG.debug( "Xml2JsonNoStreamFilter doFilter()" );
        HttpServletRequest httpServletRequest = (HttpServletRequest) servletRequest;
        HttpServletResponse httpServletResponse = (HttpServletResponse) servletResponse;

        if( jsonPreferred(httpServletRequest) ) {

            //create wrapper response to collect response content
            StringResponseWrapper wrappedResponse = new StringResponseWrapper(httpServletResponse);

            // apply filter further down the chain on wrapped response
            chain.doFilter(httpServletRequest, wrappedResponse);

            // obtain response content
            String originalResponseContent = wrappedResponse.getResponseString();

            // apply xml2json filter if response is not empty
            if (StringUtils.isNotEmpty(originalResponseContent)) {

                try {
                    //set up output stream to collect result of transformation
                    OutputStream outputStream = new ByteArrayOutputStream();

                    // transform response content with the xml2json xslt
                    TransformerUtils transformer = super.getTransformer();
                    transformer.doTransform(Collections.EMPTY_MAP,
                            new StreamSource(new StringReader(originalResponseContent)),
                            new StreamResult(outputStream));

                    // set response with the transformed json content
                    String jsonResponseContent = outputStream.toString();
                    setResponseContent(httpServletRequest, httpServletResponse, jsonResponseContent);
                }
                catch(Exception e) {
                    throw new ServletException(e);
                }
                finally {
                    httpServletResponse.getWriter().close();
                }
            }
        }
        else {
            chain.doFilter( servletRequest, servletResponse );
        }
    }

    private void setResponseContent(HttpServletRequest request, HttpServletResponse response, String content)
            throws IOException {

        response.setContentLength(content.length());
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.startsWith(RAX_SVC_JSON_MEDIA_TYPE)) {
            response.setContentType(RAX_SVC_JSON_MEDIA_TYPE);
        }
        else {
            response.setContentType(JSON_MEDIA_TYPE);
        }
        response.addHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
        response.getWriter().write(content);
    }

}
