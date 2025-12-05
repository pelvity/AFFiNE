import { Controller, Get, Query, Res } from '@nestjs/common';
import type { Response } from 'express';

@Controller('/api/calendar')
export class CalendarProxyController {
  @Get('proxy')
  async proxyCalendar(
    @Query('url') url: string,
    @Res() res: Response
  ): Promise<void> {
    if (!url || !url.includes('calendar.google.com')) {
      res.status(400).send('Invalid calendar URL');
      return;
    }

    try {
      const response = await fetch(url);
      const data = await response.text();

      res.setHeader('Content-Type', 'text/calendar');
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.send(data);
    } catch (error) {
      res.status(500).send('Failed to fetch calendar');
    }
  }
}
