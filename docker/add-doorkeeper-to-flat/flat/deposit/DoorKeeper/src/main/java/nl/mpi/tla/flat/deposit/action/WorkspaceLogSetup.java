/*
 * Copyright (C) 2015 menzowi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package nl.mpi.tla.flat.deposit.action;

import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.joran.JoranConfigurator;
import ch.qos.logback.core.joran.spi.JoranException;
import ch.qos.logback.core.util.StatusPrinter;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.util.UUID;
import nl.mpi.tla.flat.deposit.Context;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

/**
 *
 * @author menzowi
 */
public class WorkspaceLogSetup extends AbstractAction {
    
    private static final Logger logger = LoggerFactory.getLogger(WorkspaceLogSetup.class.getName());
    
    @Override
    public boolean perform(Context context) {
        if (MDC.get("sip")==null)
            MDC.put("sip","SIP_"+UUID.randomUUID());

        try {
            File dir = new File(getParameter("dir","./logs"));
            if (!dir.exists())
                FileUtils.forceMkdir(dir);
            
            File logback = dir.toPath().resolve("./logback.xml").toFile();
            
            if (!logback.exists()) {
                // create {$work}/logs/logback.xml
                PrintWriter out = new PrintWriter(logback);
                out.print(
                    "<configuration>\n" +
                    "	<appender name=\"DEVEL\" class=\"ch.qos.logback.core.FileAppender\">\n" +
                    "		<file>" + dir + "/devel.log</file>\n" +
                    "		<append>true</append>\n" +
                    "           <filter class=\"ch.qos.logback.core.filter.EvaluatorFilter\">\n" +
                    "                   <evaluator>\n" +
                    "                           <expression>return (mdc.get(\"sip\") != null &amp;&amp; ((String)mdc.get(\"sip\")).equals(\""+ MDC.get("sip") +"\"));</expression>\n" +
                    "                   </evaluator>\n" +
                    "                   <OnMismatch>DENY</OnMismatch>\n" +
                    "                   <OnMatch>ACCEPT</OnMatch>\n" +
                    "           </filter>\n" +
                    "           <encoder>\n" +
                    "                    <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} : %msg%n</pattern>\n" +
                    "           </encoder>" +
                    "	</appender>\n" +
                    "	<appender name=\"USER\" class=\"ch.qos.logback.core.FileAppender\">\n" +
                    "		<file>" + dir + "/user-log-events.xml</file>\n" +
                    "		<append>true</append>\n" +
                    "           <filter class=\"ch.qos.logback.core.filter.EvaluatorFilter\">\n" +
                    "                   <evaluator>\n" +
                    "                           <expression>return (level >= INFO &amp;&amp; mdc.get(\"sip\") != null &amp;&amp; ((String)mdc.get(\"sip\")).equals(\""+ MDC.get("sip") +"\"));</expression>\n" +
                    "                   </evaluator>\n" +
                    "                   <OnMismatch>DENY</OnMismatch>\n" +
                    "                   <OnMatch>ACCEPT</OnMatch>\n" +
                    "           </filter>\n" +
                    "           <encoder class=\"ch.qos.logback.core.encoder.LayoutWrappingEncoder\">\n" +
                    "                   <layout class=\"ch.qos.logback.classic.log4j.XMLLayout\"/>\n" +
                    "           </encoder>" +
                    "	</appender>\n" +
                    "   <logger name=\"nl.mpi.tla.flat.deposit\" level=\"DEBUG\">" +
                    "		<appender-ref ref=\"USER\" />\n" +
                    "		<appender-ref ref=\"DEVEL\" />\n" +
                    "	</logger>\n" +
                    "</configuration>"
                );
                out.close();
                // create {$work}/logs/user-log.xml
                out = new PrintWriter(dir.toPath().resolve("./user-log.xml").toFile());
                out.print(
                        "<?xml version=\"1.0\" ?>\n" +
                        "<!DOCTYPE log4j:eventSet PUBLIC \"-//APACHE//DTD LOG4J 1.2//EN\" \"log4j.dtd\" [<!ENTITY data SYSTEM \"user-log-events.xml\">]>\n" +
                        "<log4j:eventSet version=\"1.2\" xmlns:log4j=\"http://jakarta.apache.org/log4j/\">\n" +
                        "    &data;\n" +
                        "</log4j:eventSet>"
                );
                out.close();
                // copy log4j.dtd to {$work}/logs/
                Files.copy(CreateFOX.class.getResourceAsStream("/WorkspaceLog/log4j.dtd"), dir.toPath().resolve("./log4j.dtd"));
            }
            
            Logger logger = LoggerFactory.getLogger(nl.mpi.tla.flat.deposit.Flow.class);
            LoggerContext logctxt = (LoggerContext) LoggerFactory.getILoggerFactory();
            try {
                JoranConfigurator configurator = new JoranConfigurator();
                configurator.setContext(logctxt);
                configurator.doConfigure(logback.toString());
            } catch (JoranException je) {
                // StatusPrinter will handle this
            }
            StatusPrinter.printInCaseOfErrorsOrWarnings(logctxt);
            logger.info("\"Welcome to FLAT!\"\n" +
                "\"Relax,\" said the DoorKeeper,\n" +
                "\"We are programmed to receive.\n" +
                "You can check-out any time you like,\n" +
                "But you can never leave!\""
            );
        } catch (IOException ex) {
            this.logger.error("Couldn't setup the deposit log!",ex);
            return false;
        }
        return true;
    }
    
}
