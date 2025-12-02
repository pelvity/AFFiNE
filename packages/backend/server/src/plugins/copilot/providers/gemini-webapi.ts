import { createOpenAICompatible } from '@ai-sdk/openai-compatible';
import { Logger } from '@nestjs/common';

import {
    CopilotProviderNotSupported,
    CopilotProviderSideError,
} from '../../../base';
import { CopilotProvider } from './provider';
import {
    CopilotChatOptions,
    CopilotProviderType,
    ModelInputType,
    ModelOutputType,
    type ModelConditions,
    type PromptMessage,
    type StreamObject,
} from './types';
import { StreamObjectParser } from './utils';

/**
 * Configuration for Gemini WebAPI provider
 * This provider connects to a Python bridge service that wraps gemini_webapi
 */
export type GeminiWebAPIConfig = {
    /**
     * Base URL for the Python bridge service
     * Default: http://127.0.0.1:8765
     */
    baseURL: string;

    /**
     * API key for authentication (optional)
     * The bridge service uses cookies internally
     */
    apiKey?: string;

    /**
     * Enable/disable the provider
     */
    enabled?: boolean;
};

/**
 * Gemini WebAPI Provider
 *
 * This provider integrates with gemini_webapi Python library through a bridge service.
 * It provides access to Google Gemini's web app features that may not be available
 * through the official API, such as:
 * - System prompts via Gemini Gems
 * - Extension support (YouTube, Gmail, etc.)
 * - Persistent cookies with auto-refresh
 * - Image generation with natural language
 */
export class GeminiWebAPIProvider extends CopilotProvider<GeminiWebAPIConfig> {
    override readonly type = CopilotProviderType.GeminiWebAPI;

    readonly models = [
        {
            name: 'Gemini 3.0 Pro (Web)',
            id: 'gemini-3.0-pro',
            capabilities: [
                {
                    input: [
                        ModelInputType.Text,
                        ModelInputType.Image,
                        ModelInputType.Audio,
                    ],
                    output: [
                        ModelOutputType.Text,
                        ModelOutputType.Object,
                        ModelOutputType.Structured,
                    ],
                },
            ],
        },
        {
            name: 'Gemini 2.5 Flash (Web)',
            id: 'gemini-2.5-flash',
            capabilities: [
                {
                    input: [
                        ModelInputType.Text,
                        ModelInputType.Image,
                        ModelInputType.Audio,
                    ],
                    output: [
                        ModelOutputType.Text,
                        ModelOutputType.Object,
                        ModelOutputType.Structured,
                    ],
                    defaultForOutputType: true,
                },
            ],
        },
        {
            name: 'Gemini 2.5 Pro (Web)',
            id: 'gemini-2.5-pro',
            capabilities: [
                {
                    input: [
                        ModelInputType.Text,
                        ModelInputType.Image,
                        ModelInputType.Audio,
                    ],
                    output: [
                        ModelOutputType.Text,
                        ModelOutputType.Object,
                        ModelOutputType.Structured,
                    ],
                },
            ],
        },
    ];

    private instance: ReturnType<typeof createOpenAICompatible> | null = null;

    override configured(): boolean {
        return !!this.config.baseURL && this.config.enabled !== false;
    }

    protected override async setup() {
        // DEBUG: Write to log file
        const fs = await import('fs');
        const logFile = 'c:\\Users\\admin\\ProjectsIT\\personal\\AFFiNE\\gemini-debug.log';
        const logDebug = (msg: string, data?: any) => {
            const timestamp = new Date().toISOString();
            const logLine = `[${timestamp}] ${msg} ${data ? JSON.stringify(data) : ''}\n`;
            try { fs.appendFileSync(logFile, logLine); } catch (e) { }
        };

        logDebug('🚀 GeminiWebAPIProvider.setup() called');

        super.setup();

        if (!this.configured()) {
            logDebug('❌ Not configured');
            return;
        }

        // Create an OpenAI-compatible client that points to our bridge service
        logDebug('🔌 Connecting to bridge at:', this.config.baseURL);

        this.instance = createOpenAICompatible({
            name: 'gemini-bridge',
            apiKey: this.config.apiKey || 'bridge-service', // dummy key
            baseURL: this.config.baseURL.replace(/\/$/, '') + '/v1',
        });

        // Test connection to bridge service
        try {
            const response = await fetch(
                this.config.baseURL.replace(/\/$/, '') + '/health'
            );

            if (!response.ok) {
                logDebug('❌ Health check failed:', response.status);
                throw new Error(
                    `Bridge service health check failed: ${response.status}`
                );
            }

            const data: any = await response.json();
            logDebug('✅ Health check passed', data);

            if (!data.client_initialized) {
                this.logger.warn(
                    'Gemini WebAPI bridge is running but client is not initialized'
                );
            } else {
                this.logger.log('Gemini WebAPI bridge connection verified');
            }
        } catch (error) {
            logDebug('❌ Connection error:', error);
            this.logger.error(
                'Failed to connect to Gemini WebAPI bridge service',
                error
            );
            throw new CopilotProviderSideError({
                provider: this.type,
                kind: 'connection_failed',
                message: `Cannot connect to Gemini WebAPI bridge at ${this.config.baseURL}. Make sure the Python bridge service is running.`,
            });
        }
    }

    handleError(e: any) {
        // Handle bridge-specific errors
        if (e.status === 503) {
            throw new CopilotProviderSideError({
                provider: this.type,
                kind: 'service_unavailable',
                message: 'Gemini WebAPI bridge service is unavailable',
            });
        }

        if (e.status === 401 || e.status === 403) {
            throw new CopilotProviderSideError({
                provider: this.type,
                kind: 'unauthorized',
                message: 'Authentication failed. Check your Gemini cookies.',
            });
        }

        // Default error handling
        this.logger.error('Gemini WebAPI error:', e);
        throw new CopilotProviderSideError({
            provider: this.type,
            kind: 'unexpected_response',
            message: e.message || 'Unknown error from Gemini WebAPI bridge',
        });
    }

    override async text(
        cond: ModelConditions,
        messages: PromptMessage[],
        options: CopilotChatOptions = {}
    ): Promise<string> {
        // DEBUG: Write to log file
        const fs = await import('fs');
        const logFile = 'c:\\Users\\admin\\ProjectsIT\\personal\\AFFiNE\\gemini-debug.log';
        const logDebug = (msg: string, data?: any) => {
            const timestamp = new Date().toISOString();
            const logLine = `[${timestamp}] ${msg} ${data ? JSON.stringify(data) : ''}\n`;
            try { fs.appendFileSync(logFile, logLine); } catch (e) { }
        };

        logDebug('🚀 text() called', { model: cond });

        if (!this.instance) {
            throw new CopilotProviderNotSupported({
                provider: this.type,
                kind: 'text',
            });
        }

        const model = this.selectModel(cond);
        this.logger.log(`🚀 [GEMINI WEBAPI] text() called - Model: ${model.id}, Messages:`, JSON.stringify(messages.map(m => ({ role: m.role, content: typeof m.content === 'string' ? m.content.substring(0, 100) : m.content }))));

        try {
            // Use streamText and buffer it, because generateText might fail if bridge returns SSE
            const { streamText } = await import('ai');
            const result = streamText({
                model: this.instance(model.id),
                messages: this.convertMessages(messages),
                ...(options.maxTokens && { maxTokens: options.maxTokens }),
                ...(options.temperature !== null &&
                    options.temperature !== undefined && {
                    temperature: options.temperature,
                }),
            });

            let fullText = '';
            for await (const chunk of result.textStream) {
                fullText += chunk;
            }
            return fullText;
        } catch (e) {
            logDebug('❌ Error in text():', e);
            throw this.handleError(e);
        }
    }

    override async *streamText(
        cond: ModelConditions,
        messages: PromptMessage[],
        options: CopilotChatOptions = {}
    ): AsyncIterable<string> {
        // DEBUG: Write to log file (Hardcoded path)
        const fs = await import('fs');
        const logFile = 'c:\\Users\\admin\\ProjectsIT\\personal\\AFFiNE\\gemini-debug.log';

        const logDebug = (msg: string, data?: any) => {
            const timestamp = new Date().toISOString();
            const logLine = `[${timestamp}] ${msg} ${data ? JSON.stringify(data) : ''}\n`;
            try { fs.appendFileSync(logFile, logLine); } catch (e) { }
        };

        logDebug('🚀 streamText called', { model: cond, optionsTools: options.tools });

        if (!this.instance) {
            logDebug('❌ Instance not initialized');
            throw new CopilotProviderNotSupported({
                provider: this.type,
                kind: 'text',
            });
        }

        const model = this.selectModel(cond);

        // Get tools available for this request
        const tools = await this.getTools(options, model.id);

        logDebug('🔍 Raw tools from getTools:', Object.keys(tools));

        // Filter out webSearch if present (per user request)
        if (tools.web_search_exa) {
            logDebug('Removing web_search_exa');
            delete tools.web_search_exa;
        }
        if (tools.web_crawl_exa) {
            logDebug('Removing web_crawl_exa');
            delete tools.web_crawl_exa;
        }

        const hasTools = Object.keys(tools).length > 0;
        logDebug('Final tools to pass:', Object.keys(tools));

        if (hasTools) {
            this.logger.log(`🔧 [GEMINI WEBAPI] Tools enabled: ${Object.keys(tools).join(', ')}`);
        }

        try {
            logDebug('Calling streamText with tools:', hasTools);
            const { streamText } = await import('ai');

            const result = streamText({
                model: this.instance(model.id),
                messages: this.convertMessages(messages),
                tools: hasTools ? tools : undefined, // Pass tools to AI SDK
                ...(options.maxTokens && { maxTokens: options.maxTokens }),
                ...(options.temperature !== null &&
                    options.temperature !== undefined && {
                    temperature: options.temperature,
                }),
            });

            const stream = result.textStream;

            for await (const chunk of stream) {
                yield chunk;
            }
        } catch (e) {
            logDebug('❌ Error in streamText:', e);
            throw this.handleError(e);
        }
    }

    override async *streamObject(
        cond: ModelConditions,
        messages: PromptMessage[],
        options: CopilotChatOptions = {}
    ): AsyncIterable<StreamObject> {
        if (!this.instance) {
            throw new CopilotProviderNotSupported({
                provider: this.type,
                kind: 'text',
            });
        }

        const fullCond = { ...cond, outputType: ModelOutputType.Object };
        await this.checkParams({ cond: fullCond, messages, options });
        const model = this.selectModel(fullCond);

        try {
            const { streamText } = await import('ai');
            const result = streamText({
                model: this.instance(model.id),
                messages: this.convertMessages(messages),
                ...(options.maxTokens && { maxTokens: options.maxTokens }),
                ...(options.temperature !== null &&
                    options.temperature !== undefined && {
                    temperature: options.temperature,
                }),
            });

            const parser = new StreamObjectParser();
            const fullStream = result.fullStream;

            for await (const chunk of fullStream) {
                const result = parser.parse(chunk);
                if (result) {
                    yield result;
                }
            }
        } catch (e) {
            throw this.handleError(e);
        }
    }

    /**
     * Convert AFFiNE messages to the format expected by the AI SDK
     */
    private convertMessages(messages: PromptMessage[]) {
        return messages.map(msg => ({
            role: msg.role,
            content: msg.content,
            // Add support for attachments if needed
        }));
    }
}
